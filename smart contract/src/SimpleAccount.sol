// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ISimpleAccount} from "./ISimpleAccount.sol";
import {IEntryPoint} from "./IEntryPoint.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title SimpleAccount
 * @notice ERC-4337 compliant smart contract account with ECDSA signature validation.
 * @dev Inherits ISimpleAccount for full ERC-4337 compatibility.
 */
contract SimpleAccount is ISimpleAccount, ReentrancyGuard {
    using ECDSA for bytes32;

    // Constants for validation data
    uint256 private constant SIG_VALIDATION_FAILED = 1;
    uint256 private constant VALIDATION_SUCCESS = 0;

    /// @notice The owner of the account
    address public immutable owner;
    /// @notice The EntryPoint contract address
    IEntryPoint public immutable entryPoint;
    uint256 private _nonce;

    /// @notice Emitted when the account is initialized
    event SimpleAccountInitialized(
        address indexed owner,
        address indexed entryPoint
    );
    /// @notice Emitted on successful execution
    event ExecutionSuccess(address indexed target, uint256 value, bytes data);
    /// @notice Emitted on failed execution
    event ExecutionFailure(
        address indexed target,
        uint256 value,
        bytes data,
        string reason
    );

    error NotEntryPoint();
    error NotOwner();
    error InvalidNonce();
    error InvalidSignature();
    error ExecutionFailed();

    /**
     * @notice Initializes the account with an owner and entry point.
     * @param _owner The address that will own this account
     * @param _entryPoint The ERC-4337 entry point contract address
     */
    constructor(address _owner, address _entryPoint) {
        require(_owner != address(0), "Invalid owner");
        require(_entryPoint != address(0), "Invalid entry point");
        owner = _owner;
        entryPoint = IEntryPoint(_entryPoint);
        _nonce = 0;
        emit SimpleAccountInitialized(_owner, _entryPoint);
    }

    /**
     * @inheritdoc ISimpleAccount
     * @notice Validates a user operation according to ERC-4337 standards.
     * @param userOp The user operation to validate
     * @param userOpHash The hash of the user operation
     * @param missingAccountFunds The amount of funds the account needs to pay to the entry point
     * @return validationData Packed validation data (authorizer, validUntil, validAfter)
     */
    function validateUserOp(
        IEntryPoint.UserOperation calldata userOp,
        bytes32 userOpHash,
        uint256 missingAccountFunds
    ) external override returns (uint256 validationData) {
        if (msg.sender != address(entryPoint)) revert NotEntryPoint();
        if (userOp.nonce != _nonce) revert InvalidNonce();
        if (!_isValidSignature(userOpHash, userOp.signature))
            return SIG_VALIDATION_FAILED;
        if (missingAccountFunds > 0) _payPrefund(missingAccountFunds);
        _nonce++;
        return VALIDATION_SUCCESS;
    }

    /**
     * @notice Executes a call to another contract. Only callable by the entry point.
     * @param target The target contract address
     * @param value The amount of ETH to send with the call
     * @param data The call data
     */
    function execute(
        address target,
        uint256 value,
        bytes calldata data
    ) external nonReentrant {
        if (msg.sender != address(entryPoint)) revert NotEntryPoint();
        (bool success, bytes memory result) = target.call{value: value}(data);
        if (success) {
            emit ExecutionSuccess(target, value, data);
        } else {
            string memory reason = _getRevertReason(result);
            emit ExecutionFailure(target, value, data, reason);
            revert ExecutionFailed();
        }
    }

    /**
     * @notice Executes a batch of calls. Only callable by the entry point.
     * @param targets Array of target contract addresses
     * @param values Array of ETH amounts to send with each call
     * @param datas Array of call data
     */
    function executeBatch(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata datas
    ) external nonReentrant {
        if (msg.sender != address(entryPoint)) revert NotEntryPoint();
        require(
            targets.length == values.length && targets.length == datas.length,
            "Array length mismatch"
        );
        for (uint256 i = 0; i < targets.length; i++) {
            require(targets[i] != address(0), "Invalid target");
            (bool success, bytes memory result) = targets[i].call{
                value: values[i]
            }(datas[i]);
            if (success) {
                emit ExecutionSuccess(targets[i], values[i], datas[i]);
            } else {
                string memory reason = _getRevertReason(result);
                emit ExecutionFailure(targets[i], values[i], datas[i], reason);
                revert ExecutionFailed();
            }
        }
    }

    /// @notice Returns the current nonce for this account
    /// @return The current nonce
    function nonce() public view returns (uint256) {
        return _nonce;
    }

    /// @notice Allows the account to receive ETH
    receive() external payable {}

    /// @notice Fallback function to handle calls with no matching function signature
    fallback() external payable {}

    /**
     * @dev Validates if a signature is valid for the given hash.
     * @param hash The hash to validate
     * @param signature The signature to validate
     * @return True if the signature is valid, false otherwise
     */
    function _isValidSignature(
        bytes32 hash,
        bytes calldata signature
    ) internal view returns (bool) {
        if (signature.length != 65) return false;
        bytes32 messageHash = MessageHashUtils.toEthSignedMessageHash(hash);
        address recovered = messageHash.recover(signature);
        return recovered == owner;
    }

    /**
     * @dev Pays the required funds to the entry point.
     * @param missingAccountFunds The amount of funds to pay
     */
    function _payPrefund(uint256 missingAccountFunds) internal {
        if (missingAccountFunds > 0) {
            (bool success, ) = payable(address(entryPoint)).call{
                value: missingAccountFunds
            }("");
            require(success, "Failed to pay prefund");
        }
    }

    /**
     * @dev Extracts the revert reason from a failed call.
     * @param result The result data from a failed call
     * @return The revert reason as a string
     */
    function _getRevertReason(
        bytes memory result
    ) internal pure returns (string memory) {
        if (result.length == 0) return "Unknown error";
        if (result.length >= 68) {
            bytes4 errorSelector;
            assembly {
                errorSelector := mload(add(result, 32))
            }
            if (errorSelector == bytes4(keccak256("Error(string)"))) {
                string memory reason;
                assembly {
                    reason := add(result, 68)
                }
                return reason;
            }
        }
        return string(abi.encodePacked("0x", _toHexString(result)));
    }

    /**
     * @dev Converts bytes to a hex string.
     * @param data The bytes to convert
     * @return The hex string representation
     */
    function _toHexString(
        bytes memory data
    ) internal pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint256 i = 0; i < data.length; i++) {
            str[2 + i * 2] = alphabet[uint8(data[i] >> 4)];
            str[3 + i * 2] = alphabet[uint8(data[i] & 0x0f)];
        }
        return string(str);
    }

    /// @notice Allows the owner to withdraw ETH from the account
    /// @param amount The amount to withdraw
    /// @param target The address to send the ETH to
    function withdraw(uint256 amount, address payable target) external {
        if (msg.sender != owner) revert NotOwner();
        require(target != address(0), "Invalid target");
        require(amount <= address(this).balance, "Insufficient balance");
        (bool success, ) = target.call{value: amount}("");
        require(success, "Withdrawal failed");
    }

    /// @notice Returns the current balance of the account in wei
    /// @return The current balance in wei
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
