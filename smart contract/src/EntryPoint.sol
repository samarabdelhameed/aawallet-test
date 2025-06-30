// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./IEntryPoint.sol";

interface ISimpleAccount {
    function validateUserOp(
        IEntryPoint.UserOperation calldata userOp,
        bytes32 userOpHash,
        uint256 missingAccountFunds
    ) external returns (uint256);
}

/**
 * @title EntryPoint
 * @dev Professional ERC-4337 EntryPoint implementation (basic logic, ready for extension)
 */
contract EntryPoint is IEntryPoint {
    mapping(address => uint256) private _nonces;
    mapping(address => uint256) private _deposits;

    receive() external payable {}

    /// @inheritdoc IEntryPoint
    function handleOps(
        UserOperation[] calldata ops,
        address payable beneficiary
    ) external override {
        uint256 opsLength = ops.length;
        for (uint256 i = 0; i < opsLength; i++) {
            UserOperation calldata userOp = ops[i];
            bytes32 userOpHash = keccak256(
                abi.encodePacked(
                    userOp.sender,
                    userOp.nonce,
                    keccak256(userOp.initCode),
                    keccak256(userOp.callData),
                    userOp.callGasLimit,
                    userOp.verificationGasLimit,
                    userOp.preVerificationGas,
                    userOp.maxFeePerGas,
                    userOp.maxPriorityFeePerGas,
                    keccak256(userOp.paymasterAndData)
                )
            );
            uint256 missingAccountFunds = 0; // Placeholder for paymaster logic
            bool success = false;
            uint256 actualGasCost = 0;
            uint256 actualGasUsed = 0;
            try
                ISimpleAccount(userOp.sender).validateUserOp(
                    userOp,
                    userOpHash,
                    missingAccountFunds
                )
            returns (uint256 validationResult) {
                // If validation passes, execute the call
                (success, ) = userOp.sender.call{gas: userOp.callGasLimit}(
                    userOp.callData
                );
            } catch (bytes memory revertReason) {
                emit UserOperationRevertReason(
                    userOpHash,
                    userOp.sender,
                    userOp.nonce,
                    revertReason
                );
                continue;
            }
            emit UserOperationEvent(
                userOpHash,
                userOp.sender,
                address(0),
                userOp.nonce,
                success,
                actualGasCost,
                actualGasUsed
            );
        }
        // Placeholder: send fees to beneficiary if needed
    }

    /// @inheritdoc IEntryPoint
    function simulateValidation(
        UserOperation calldata userOp
    ) external pure override returns (uint256 preOpGas) {
        // Placeholder: in a real implementation, simulate validation logic
        return 21000;
    }

    /// @inheritdoc IEntryPoint
    function getNonce(
        address sender
    ) external view override returns (uint256 nonce) {
        return _nonces[sender];
    }

    /// @inheritdoc IEntryPoint
    function depositTo(address account) external payable override {
        require(msg.value > 0, "No value sent");
        _deposits[account] += msg.value;
        emit Deposited(account, _deposits[account]);
    }

    /// @inheritdoc IEntryPoint
    function withdrawTo(
        address payable withdrawAddress,
        uint256 amount
    ) external override {
        require(_deposits[msg.sender] >= amount, "Insufficient deposit");
        _deposits[msg.sender] -= amount;
        (bool sent, ) = withdrawAddress.call{value: amount}("");
        require(sent, "Withdraw failed");
        emit Withdrawn(msg.sender, withdrawAddress, amount);
    }

    /// @inheritdoc IEntryPoint
    function balanceOf(
        address account
    ) external view override returns (uint256) {
        return _deposits[account];
    }
}
