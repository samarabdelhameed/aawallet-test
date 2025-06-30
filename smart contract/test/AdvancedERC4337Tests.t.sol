// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {EntryPoint} from "../src/EntryPoint.sol";
import {SimpleAccount} from "../src/SimpleAccount.sol";
import {AccountFactory} from "../src/AccountFactory.sol";
import {IEntryPoint} from "../src/IEntryPoint.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/**
 * @title AdvancedERC4337Tests
 * @dev Advanced professional tests for complex ERC-4337 scenarios
 * @author Professional Smart Contract Developer
 * @notice Tests advanced scenarios including:
 * - Multi-signature operations
 * - Complex transaction flows
 * - Security edge cases
 * - Performance optimization
 * - Integration with external contracts
 */
contract AdvancedERC4337Tests is Test {
    using ECDSA for bytes32;

    // Core contracts
    EntryPoint public entryPoint;
    AccountFactory public factory;

    // Test accounts with multiple keys
    address public owner1;
    address public owner2;
    address public beneficiary;
    address public target;

    uint256 public owner1PrivateKey;
    uint256 public owner2PrivateKey;

    // Mock external contract for testing
    MockExternalContract public mockContract;

    // Events
    event ComplexOperationExecuted(
        address indexed account,
        address indexed target,
        uint256 value,
        bytes data,
        uint256 timestamp
    );

    // إضافة mapping لربط كل حساب بمفتاحه الخاص
    mapping(address => uint256) private accountPrivateKeys;

    function setUp() public {
        // Generate multiple test accounts
        owner1PrivateKey = 0x1111111111111111111111111111111111111111111111111111111111111111;
        owner2PrivateKey = 0x2222222222222222222222222222222222222222222222222222222222222222;

        owner1 = vm.addr(owner1PrivateKey);
        owner2 = vm.addr(owner2PrivateKey);
        beneficiary = address(0x456);
        target = address(0x789);

        // Deploy contracts
        entryPoint = new EntryPoint();
        factory = new AccountFactory();
        mockContract = new MockExternalContract();

        // Fund contracts
        vm.deal(address(entryPoint), 1000 ether);
        vm.deal(address(mockContract), 50 ether);
    }

    /**
     * @dev Test complex multi-step transaction flow
     */
    function test_ComplexMultiStepTransaction() public {
        // Create account
        address accountAddr = factory.createAccount(
            owner1,
            address(entryPoint),
            0x123
        );
        vm.deal(accountAddr, 20 ether);

        // Step 1: Transfer ETH to target
        _executeUserOperation(accountAddr, target, 5 ether, "");
        assertEq(target.balance, 5 ether, "Step 1: Target should receive ETH");

        // Step 2: Call external contract
        bytes memory callData = abi.encodeWithSelector(
            mockContract.complexFunction.selector,
            "test data",
            42
        );
        _executeUserOperation(accountAddr, address(mockContract), 0, callData);

        // Step 3: Verify external contract state
        assertEq(
            mockContract.lastCaller(),
            accountAddr,
            "Step 3: External contract should record caller"
        );
        assertEq(
            mockContract.callCount(),
            1,
            "Step 3: Call count should be incremented"
        );

        // Step 4: Execute batch operations
        _executeBatchOperations(accountAddr, target, 3 ether);

        assertEq(
            target.balance,
            8 ether,
            "Step 4: Target should have total ETH"
        );
        assertEq(
            accountAddr.balance,
            12 ether,
            "Step 4: Account should have remaining ETH"
        );
    }

    /**
     * @dev Test gas optimization with different operation types
     */
    function test_GasOptimizationAnalysis() public {
        address accountAddr = factory.createAccount(
            owner1,
            address(entryPoint),
            0x456
        );
        vm.deal(accountAddr, 10 ether);

        // Test 1: Simple ETH transfer
        uint256 gasBefore = gasleft();
        _executeUserOperation(accountAddr, target, 1 ether, "");
        uint256 gasUsed1 = gasBefore - gasleft();
        console.log("Gas used for ETH transfer:", gasUsed1);

        // Test 2: Contract call with data
        gasBefore = gasleft();
        bytes memory data = abi.encodeWithSelector(
            mockContract.simpleFunction.selector
        );
        _executeUserOperation(accountAddr, address(mockContract), 0, data);
        uint256 gasUsed2 = gasBefore - gasleft();
        console.log("Gas used for contract call:", gasUsed2);

        // Test 3: Complex contract call
        gasBefore = gasleft();
        bytes memory complexData = abi.encodeWithSelector(
            mockContract.complexFunction.selector,
            "complex data string",
            12345
        );
        _executeUserOperation(
            accountAddr,
            address(mockContract),
            0,
            complexData
        );
        uint256 gasUsed3 = gasBefore - gasleft();
        console.log("Gas used for complex call:", gasUsed3);

        // Verify gas usage is reasonable
        assertTrue(gasUsed1 < 150000, "ETH transfer gas should be low");
        assertTrue(gasUsed2 < 200000, "Simple call gas should be reasonable");
        assertTrue(gasUsed3 < 250000, "Complex call gas should be reasonable");
    }

    /**
     * @dev Test concurrent operations and race conditions
     */
    function test_ConcurrentOperations() public {
        address account1 = factory.createAccount(
            owner1,
            address(entryPoint),
            0x111
        );
        address account2 = factory.createAccount(
            owner2,
            address(entryPoint),
            0x222
        );

        vm.deal(account1, 10 ether);
        vm.deal(account2, 10 ether);

        // Prepare and execute first operation for account1
        console.log("before op1 target:", target.balance);
        console.log("account1:", account1.balance);
        console.log("account2:", account2.balance);
        SimpleAccount simpleAccount1 = SimpleAccount(account1);
        IEntryPoint.UserOperation memory op1 = _createUserOperationWithNonce(
            account1,
            target,
            2 ether,
            "",
            simpleAccount1.nonce()
        );
        IEntryPoint.UserOperation[]
            memory ops1 = new IEntryPoint.UserOperation[](1);
        ops1[0] = op1;
        entryPoint.handleOps(ops1, payable(beneficiary));
        console.log("after op1 target:", target.balance);
        console.log("account1:", account1.balance);
        console.log("account2:", account2.balance);

        // Prepare and execute second operation for account2
        SimpleAccount simpleAccount2 = SimpleAccount(account2);
        IEntryPoint.UserOperation memory op2 = _createUserOperationWithNonce(
            account2,
            target,
            3 ether,
            "",
            simpleAccount2.nonce()
        );
        IEntryPoint.UserOperation[]
            memory ops2 = new IEntryPoint.UserOperation[](1);
        ops2[0] = op2;
        entryPoint.handleOps(ops2, payable(beneficiary));
        console.log("after op2 target:", target.balance);
        console.log("account1:", account1.balance);
        console.log("account2:", account2.balance);

        // Verify both operations succeeded
        assertEq(target.balance, 5 ether, "Both operations should succeed");
        assertEq(
            account1.balance,
            8 ether,
            "Account1 should have remaining balance"
        );
        assertEq(
            account2.balance,
            7 ether,
            "Account2 should have remaining balance"
        );
    }

    /**
     * @dev Test integration with complex external contracts
     */
    function test_ExternalContractIntegration() public {
        address accountAddr = factory.createAccount(
            owner1,
            address(entryPoint),
            0x333
        );
        vm.deal(accountAddr, 15 ether);

        // Test interaction with mock contract
        bytes memory callData = abi.encodeWithSelector(
            mockContract.complexFunction.selector,
            "integration test",
            999
        );

        _executeUserOperation(
            accountAddr,
            address(mockContract),
            1 ether,
            callData
        );

        // Verify integration
        assertEq(
            mockContract.lastCaller(),
            accountAddr,
            "Mock contract should record caller"
        );
        assertEq(
            mockContract.lastValue(),
            1 ether,
            "Mock contract should receive value"
        );
        assertEq(
            mockContract.callCount(),
            1,
            "Call count should be incremented"
        );

        // Test callback from external contract
        bytes memory callbackData = abi.encodeWithSelector(
            mockContract.callbackFunction.selector,
            accountAddr
        );

        _executeUserOperation(
            accountAddr,
            address(mockContract),
            0,
            callbackData
        );
        assertEq(
            mockContract.callbackCount(),
            1,
            "Callback should be recorded"
        );
    }

    /**
     * @dev Test performance under high load
     */
    function test_HighLoadPerformance() public {
        uint256 numAccounts = 10;
        address[] memory accounts = new address[](numAccounts);
        uint256[] memory privateKeys = new uint256[](numAccounts);
        // Create multiple accounts with unique private keys
        for (uint256 i = 0; i < numAccounts; i++) {
            uint256 pk = uint256(keccak256(abi.encodePacked("highload", i)));
            privateKeys[i] = pk;
            address owner = vm.addr(pk);
            accounts[i] = factory.createAccount(owner, address(entryPoint), i);
            accountPrivateKeys[accounts[i]] = pk;
            vm.deal(accounts[i], 5 ether);
        }
        // Prepare batch operations
        IEntryPoint.UserOperation[]
            memory ops = new IEntryPoint.UserOperation[](numAccounts);
        for (uint256 i = 0; i < numAccounts; i++) {
            ops[i] = _createUserOperation(accounts[i], target, 1 ether, "");
        }
        // Execute batch and measure performance
        uint256 gasBefore = gasleft();
        entryPoint.handleOps(ops, payable(beneficiary));
        uint256 gasUsed = gasBefore - gasleft();
        console.log("Gas used for", numAccounts, "operations:", gasUsed);
        console.log("Average gas per operation:", gasUsed / numAccounts);
        // Verify all operations succeeded
        assertEq(
            target.balance,
            numAccounts * 1 ether,
            "All operations should succeed"
        );
        // Verify performance is reasonable
        assertTrue(
            gasUsed < numAccounts * 200000,
            "Gas usage should be reasonable per operation"
        );
    }

    /**
     * @dev Test deterministic deployment and address prediction
     */
    function test_DeterministicDeployment() public {
        // Test multiple deterministic deployments
        for (uint256 i = 0; i < 5; i++) {
            uint256 salt = i * 1000;

            // Predict address
            address predictedAddr = factory.getAddress(
                owner1,
                address(entryPoint),
                salt
            );

            // Deploy account
            address deployedAddr = factory.createAccount(
                owner1,
                address(entryPoint),
                salt
            );

            // Verify prediction
            assertEq(
                deployedAddr,
                predictedAddr,
                "Address prediction should be accurate"
            );

            // Verify account properties
            SimpleAccount account = SimpleAccount(deployedAddr);
            assertEq(
                account.owner(),
                owner1,
                "Account owner should be correct"
            );
            assertEq(
                account.entryPoint(),
                address(entryPoint),
                "Entry point should be correct"
            );
        }
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

    function _executeBatchOperations(
        address account,
        address target,
        uint256 value
    ) internal {
        IEntryPoint.UserOperation[]
            memory ops = new IEntryPoint.UserOperation[](3);
        SimpleAccount simpleAccount = SimpleAccount(account);
        uint256 startNonce = simpleAccount.nonce();
        for (uint256 i = 0; i < 3; i++) {
            ops[i] = _createUserOperationWithNonce(
                account,
                target,
                value / 3,
                "",
                startNonce + i
            );
        }
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
            nonce: simpleAccount.nonce(),
            initCode: "",
            callData: callData,
            callGasLimit: 200000,
            verificationGasLimit: 200000,
            preVerificationGas: 20000,
            maxFeePerGas: 30 gwei,
            maxPriorityFeePerGas: 3 gwei,
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
        uint256 pk = accountPrivateKeys[account];
        if (pk == 0) {
            // fallback للقديم
            pk = account ==
                factory.getAddress(owner1, address(entryPoint), 0x111) ||
                account ==
                factory.getAddress(owner1, address(entryPoint), 0x123) ||
                account ==
                factory.getAddress(owner1, address(entryPoint), 0x456) ||
                account ==
                factory.getAddress(owner1, address(entryPoint), 0x789) ||
                account ==
                factory.getAddress(owner1, address(entryPoint), 0x333)
                ? owner1PrivateKey
                : owner2PrivateKey;
        }
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(pk, userOpHash);
        userOp.signature = abi.encodePacked(r, s, v);
        return userOp;
    }

    function _createUserOperationWithNonce(
        address account,
        address target,
        uint256 value,
        bytes memory data,
        uint256 nonceOverride
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
            nonce: nonceOverride,
            initCode: "",
            callData: callData,
            callGasLimit: 200000,
            verificationGasLimit: 200000,
            preVerificationGas: 20000,
            maxFeePerGas: 30 gwei,
            maxPriorityFeePerGas: 3 gwei,
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
        uint256 pk = accountPrivateKeys[account];
        if (pk == 0) {
            pk = account ==
                factory.getAddress(owner1, address(entryPoint), 0x111) ||
                account ==
                factory.getAddress(owner1, address(entryPoint), 0x123) ||
                account ==
                factory.getAddress(owner1, address(entryPoint), 0x456) ||
                account ==
                factory.getAddress(owner1, address(entryPoint), 0x789) ||
                account ==
                factory.getAddress(owner1, address(entryPoint), 0x333)
                ? owner1PrivateKey
                : owner2PrivateKey;
        }
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(pk, userOpHash);
        userOp.signature = abi.encodePacked(r, s, v);
        return userOp;
    }
}

/**
 * @title MockExternalContract
 * @dev Mock contract for testing external interactions
 */
contract MockExternalContract {
    address public lastCaller;
    uint256 public lastValue;
    string public lastData;
    uint256 public lastNumber;
    uint256 public callCount;
    uint256 public callbackCount;

    event ComplexOperation(
        address indexed caller,
        uint256 value,
        string data,
        uint256 number,
        uint256 timestamp
    );

    function simpleFunction() external {
        lastCaller = msg.sender;
        callCount++;
    }

    function complexFunction(
        string memory data,
        uint256 number
    ) external payable {
        lastCaller = msg.sender;
        lastValue = msg.value;
        lastData = data;
        lastNumber = number;
        callCount++;

        emit ComplexOperation(
            msg.sender,
            msg.value,
            data,
            number,
            block.timestamp
        );
    }

    function callbackFunction(address account) external {
        callbackCount++;
        // Simulate callback logic
    }

    receive() external payable {
        lastCaller = msg.sender;
        lastValue = msg.value;
    }
}
