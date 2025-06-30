// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title IEntryPoint
 * @dev ERC-4337 EntryPoint interface, based on the official specification.
 */
interface IEntryPoint {
    /**
     * @dev UserOperation struct as defined in ERC-4337
     */
    struct UserOperation {
        address sender;
        uint256 nonce;
        bytes initCode;
        bytes callData;
        uint256 callGasLimit;
        uint256 verificationGasLimit;
        uint256 preVerificationGas;
        uint256 maxFeePerGas;
        uint256 maxPriorityFeePerGas;
        bytes paymasterAndData;
        bytes signature;
    }

    /**
     * @dev Emitted when a UserOperation is successfully executed.
     */
    event UserOperationEvent(
        bytes32 indexed userOpHash,
        address indexed sender,
        address paymaster,
        uint256 nonce,
        bool success,
        uint256 actualGasCost,
        uint256 actualGasUsed
    );

    /**
     * @dev Emitted when a UserOperation fails validation.
     */
    event UserOperationRevertReason(
        bytes32 indexed userOpHash,
        address indexed sender,
        uint256 nonce,
        bytes revertReason
    );

    /**
     * @dev Emitted when a deposit is made.
     */
    event Deposited(address indexed account, uint256 totalDeposit);

    /**
     * @dev Emitted when a withdrawal is made.
     */
    event Withdrawn(
        address indexed account,
        address indexed withdrawAddress,
        uint256 amount
    );

    /**
     * @notice Handle a batch of UserOperations.
     * @param ops The operations to execute.
     * @param beneficiary The address to receive the fees.
     */
    function handleOps(
        UserOperation[] calldata ops,
        address payable beneficiary
    ) external;

    /**
     * @notice Simulate the validation of a UserOperation.
     * @param userOp The UserOperation to validate.
     * @return preOpGas The gas used for validation.
     */
    function simulateValidation(
        UserOperation calldata userOp
    ) external returns (uint256 preOpGas);

    /**
     * @notice Get the nonce for a given sender.
     * @param sender The address of the account.
     * @return nonce The current nonce.
     */
    function getNonce(address sender) external view returns (uint256 nonce);

    /**
     * @notice Deposit ETH for an account.
     * @param account The address to deposit for.
     */
    function depositTo(address account) external payable;

    /**
     * @notice Withdraw ETH from the contract.
     * @param withdrawAddress The address to withdraw to.
     * @param amount The amount to withdraw.
     */
    function withdrawTo(
        address payable withdrawAddress,
        uint256 amount
    ) external;

    /**
     * @notice Get the deposit of an account.
     * @param account The address to check.
     * @return The deposit amount.
     */
    function balanceOf(address account) external view returns (uint256);
}
