// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {EntryPoint} from "../src/EntryPoint.sol";
import {SimpleAccount} from "../src/SimpleAccount.sol";
import {AccountFactory} from "../src/AccountFactory.sol";
import {IEntryPoint} from "../src/IEntryPoint.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract ERC4337IntegrationTest is Test {
    using ECDSA for bytes32;

    // Core contracts
    EntryPoint public entryPoint;
    AccountFactory public factory;

    // Test accounts
    address public owner;
    address public beneficiary;
    address public target;

    // Test data
    uint256 public ownerPrivateKey;
    uint256 public constant SALT = 0x1234567890abcdef;

    // Events for testing
    event UserOperationEvent(
        address indexed sender,
        address indexed target,
        uint256 value,
        bytes data
    );

    function setUp() public {
        // Generate deterministic test accounts
        ownerPrivateKey = 0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef;
        owner = vm.addr(ownerPrivateKey);
        beneficiary = address(0x456);
        target = address(0x789);

        // Deploy contracts
        entryPoint = new EntryPoint();
        factory = new AccountFactory();

        // Fund the entry point for deposits
        vm.deal(address(entryPoint), 100 ether);
    }

    /**
     * @dev Test complete user operation flow from account creation to execution
     */
    function test_CompleteUserOperationFlow() public {
        // 1. Create account
        address accountAddr = factory.createAccount(
            owner,
            address(entryPoint),
            SALT
        );
        SimpleAccount account = SimpleAccount(accountAddr);

        // 2. Fund the account
        vm.deal(accountAddr, 10 ether);

        // 3. Prepare user operation
        bytes memory callData = abi.encodeWithSelector(
            account.execute.selector,
            target,
            1 ether,
            abi.encodeWithSelector(this.receiveEther.selector)
        );

        IEntryPoint.UserOperation memory userOp = IEntryPoint.UserOperation({
            sender: accountAddr,
            nonce: entryPoint.getNonce(accountAddr),
            initCode: "",
            callData: callData,
            callGasLimit: 100000,
            verificationGasLimit: 100000,
            preVerificationGas: 10000,
            maxFeePerGas: 20 gwei,
            maxPriorityFeePerGas: 2 gwei,
            paymasterAndData: "",
            signature: ""
        });

        // 4. Sign the user operation
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
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, userOpHash);
        userOp.signature = abi.encodePacked(r, s, v);

        // 5. Execute the user operation
        IEntryPoint.UserOperation[]
            memory ops = new IEntryPoint.UserOperation[](1);
        ops[0] = userOp;

        entryPoint.handleOps(ops, payable(beneficiary));

        // 6. Verify results
        assertEq(target.balance, 1 ether, "Target should receive 1 ether");
        assertEq(
            accountAddr.balance,
            9 ether,
            "Account should have 9 ether remaining"
        );
    }

    /**
     * @dev Test account creation with deterministic addresses
     */
    function test_DeterministicAccountCreation() public {
        address expectedAddr1 = factory.getAddress(
            owner,
            address(entryPoint),
            SALT
        );
        address accountAddr1 = factory.createAccount(
            owner,
            address(entryPoint),
            SALT
        );

        assertEq(
            accountAddr1,
            expectedAddr1,
            "Account address should be deterministic"
        );

        // Create another account with different salt
        address expectedAddr2 = factory.getAddress(
            owner,
            address(entryPoint),
            SALT + 1
        );
        address accountAddr2 = factory.createAccount(
            owner,
            address(entryPoint),
            SALT + 1
        );

        assertEq(
            accountAddr2,
            expectedAddr2,
            "Second account address should be deterministic"
        );
        assertTrue(
            accountAddr1 != accountAddr2,
            "Different salts should produce different addresses"
        );
    }

    /**
     * @dev Test signature validation with various scenarios
     */
    function test_SignatureValidation() public {
        address accountAddr = factory.createAccount(
            owner,
            address(entryPoint),
            SALT
        );
        SimpleAccount account = SimpleAccount(accountAddr);

        // إعداد userOp مطابق للعقد
        bytes memory callData = abi.encodeWithSelector(
            account.execute.selector,
            target,
            0,
            ""
        );
        IEntryPoint.UserOperation memory userOp = IEntryPoint.UserOperation({
            sender: accountAddr,
            nonce: 0,
            initCode: "",
            callData: callData,
            callGasLimit: 100000,
            verificationGasLimit: 100000,
            preVerificationGas: 10000,
            maxFeePerGas: 20 gwei,
            maxPriorityFeePerGas: 2 gwei,
            paymasterAndData: "",
            signature: ""
        });
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
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, userOpHash);
        bytes memory signature = abi.encodePacked(r, s, v);

        // تحقق من صحة التوقيع
        address recoveredSigner = ECDSA.recover(userOpHash, signature);
        assertEq(recoveredSigner, owner, "Signature should be valid");

        // تحقق من توقيع غير صحيح
        bytes memory invalidSignature = abi.encodePacked(r, s, uint8(v + 1));
        address invalidRecovered = ECDSA.recover(userOpHash, invalidSignature);
        assertTrue(
            invalidRecovered != owner,
            "Invalid signature should not recover owner"
        );
    }

    /**
     * @dev Test nonce management and replay protection
     */
    function test_NonceManagement() public {
        address accountAddr = factory.createAccount(
            owner,
            address(entryPoint),
            SALT
        );
        SimpleAccount account = SimpleAccount(accountAddr);

        uint256 nonce1 = account.nonce();
        uint256 nonce2 = account.nonce();

        assertEq(nonce1, nonce2, "Nonce should remain constant until used");

        // Execute a user operation to increment nonce
        _executeUserOperation(accountAddr, target, 0, "");

        uint256 nonce3 = account.nonce();
        assertEq(nonce3, nonce1 + 1, "Nonce should increment after operation");
    }

    /**
     * @dev Test gas optimization and limits
     */
    function test_GasOptimization() public {
        address accountAddr = factory.createAccount(
            owner,
            address(entryPoint),
            SALT
        );
        vm.deal(accountAddr, 10 ether);

        // Test with minimal gas
        uint256 gasBefore = gasleft();
        _executeUserOperation(accountAddr, target, 0, "");
        uint256 gasUsed = gasBefore - gasleft();

        console.log("Gas used for user operation:", gasUsed);
        assertTrue(gasUsed < 200000, "Gas usage should be reasonable");
    }

    /**
     * @dev Test edge cases and error conditions
     */
    function test_EdgeCases() public {
        address accountAddr = factory.createAccount(
            owner,
            address(entryPoint),
            SALT
        );

        // Test with zero value transaction
        _executeUserOperation(accountAddr, target, 0, "");

        // Test with empty call data
        _executeUserOperation(accountAddr, target, 0, "");

        // Test with invalid target (should still work)
        _executeUserOperation(accountAddr, address(0), 0, "");
    }

    /**
     * @dev Test multiple user operations in batch
     */
    function test_BatchUserOperations() public {
        address account1 = factory.createAccount(
            owner,
            address(entryPoint),
            SALT
        );
        address account2 = factory.createAccount(
            owner,
            address(entryPoint),
            SALT + 1
        );

        vm.deal(account1, 5 ether);
        vm.deal(account2, 5 ether);

        IEntryPoint.UserOperation[]
            memory ops = new IEntryPoint.UserOperation[](2);

        // Prepare first operation
        ops[0] = _createUserOperation(account1, target, 1 ether, "");

        // Prepare second operation
        ops[1] = _createUserOperation(account2, target, 1 ether, "");

        // Execute batch
        entryPoint.handleOps(ops, payable(beneficiary));

        assertEq(
            target.balance,
            2 ether,
            "Target should receive 2 ether total"
        );
    }

    /**
     * @dev Test account factory bytecode consistency
     */
    function test_AccountFactoryBytecode() public {
        bytes memory bytecode = factory.getBytecode(owner, address(entryPoint));
        assertTrue(bytecode.length > 0, "Bytecode should not be empty");

        // Verify bytecode contains expected patterns
        bool hasOwner = false;
        bool hasEntryPoint = false;

        bytes20 ownerBytes = bytes20(owner);
        bytes20 entryPointBytes = bytes20(address(entryPoint));
        for (uint i = 0; i <= bytecode.length - 20; i++) {
            bytes20 chunk = slice20(bytecode, i);
            if (chunk == ownerBytes) {
                hasOwner = true;
            }
            if (chunk == entryPointBytes) {
                hasEntryPoint = true;
            }
        }

        assertTrue(hasOwner, "Bytecode should contain owner address");
        assertTrue(
            hasEntryPoint,
            "Bytecode should contain entry point address"
        );
    }

    /**
     * @dev Test deposit and withdrawal functionality
     */
    function test_DepositAndWithdrawal() public {
        address accountAddr = factory.createAccount(
            owner,
            address(entryPoint),
            SALT
        );

        // Test deposit
        uint256 depositAmount = 1 ether;
        entryPoint.depositTo{value: depositAmount}(accountAddr);

        assertEq(
            entryPoint.balanceOf(accountAddr),
            depositAmount,
            "Deposit should be recorded"
        );

        // Test withdrawal
        uint256 withdrawAmount = 0.5 ether;
        vm.prank(accountAddr);
        entryPoint.withdrawTo(payable(owner), withdrawAmount);

        assertEq(
            entryPoint.balanceOf(accountAddr),
            depositAmount - withdrawAmount,
            "Balance should be reduced"
        );
        assertEq(
            owner.balance,
            withdrawAmount,
            "Owner should receive withdrawn amount"
        );
    }

    // Helper functions
    function _executeUserOperation(
        address account,
        address target,
        uint256 value,
        bytes memory data
    ) internal {
        IEntryPoint.UserOperation memory userOp = _createUserOperation(
            account,
            target,
            value,
            data
        );
        IEntryPoint.UserOperation[]
            memory ops = new IEntryPoint.UserOperation[](1);
        ops[0] = userOp;
        entryPoint.handleOps(ops, payable(beneficiary));
    }

    function _createUserOperation(
        address account,
        address target,
        uint256 value,
        bytes memory data
    ) internal view returns (IEntryPoint.UserOperation memory) {
        SimpleAccount simpleAccount = SimpleAccount(account);
        bytes memory callData = abi.encodeWithSelector(
            simpleAccount.execute.selector,
            target,
            value,
            data
        );

        IEntryPoint.UserOperation memory userOp = IEntryPoint.UserOperation({
            sender: account,
            nonce: entryPoint.getNonce(account),
            initCode: "",
            callData: callData,
            callGasLimit: 100000,
            verificationGasLimit: 100000,
            preVerificationGas: 10000,
            maxFeePerGas: 20 gwei,
            maxPriorityFeePerGas: 2 gwei,
            paymasterAndData: "",
            signature: ""
        });

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
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, userOpHash);
        userOp.signature = abi.encodePacked(r, s, v);

        return userOp;
    }

    // Function to receive ether for testing
    function receiveEther() external payable {
        emit UserOperationEvent(msg.sender, address(this), msg.value, "");
    }

    // Receive function for the contract
    receive() external payable {}

    // Helper to extract 20 bytes from bytes array
    function slice20(
        bytes memory data,
        uint256 start
    ) internal pure returns (bytes20 result) {
        require(data.length >= start + 20, "out of range");
        assembly {
            result := mload(add(add(data, 0x20), start))
        }
    }
}
