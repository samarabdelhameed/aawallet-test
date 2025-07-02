// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {SimpleAccount} from "../src/SimpleAccount.sol";
import {IEntryPoint} from "../src/IEntryPoint.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract DummyEntryPoint {
    receive() external payable {}
}

contract SimpleAccountTest is Test {
    SimpleAccount public account;
    DummyEntryPoint dummy;
    uint256 private ownerPrivateKey = 0x123;
    address public owner;
    address public user = address(0x456);
    address public entryPoint;

    function setUp() public {
        owner = vm.addr(ownerPrivateKey);
        dummy = new DummyEntryPoint();
        entryPoint = address(dummy);
        account = new SimpleAccount(owner, entryPoint);
    }

    /// @notice Helper to build a compliant ERC-4337 UserOp hash
    function getUserOpHash(
        IEntryPoint.UserOperation memory op
    ) public pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    op.sender,
                    op.nonce,
                    keccak256(op.initCode),
                    keccak256(op.callData),
                    op.callGasLimit,
                    op.verificationGasLimit,
                    op.preVerificationGas,
                    op.maxFeePerGas,
                    op.maxPriorityFeePerGas,
                    keccak256(op.paymasterAndData)
                )
            );
    }

    /// @notice Helper to sign a userOp hash using the owner's key
    function signUserOpHash(
        bytes32 userOpHash
    ) public view returns (bytes memory) {
        bytes32 ethHash = MessageHashUtils.toEthSignedMessageHash(userOpHash);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, ethHash);
        return abi.encodePacked(r, s, v);
    }

    /// @notice Helper to build a basic valid UserOperation
    function buildBasicUserOp()
        internal
        view
        returns (IEntryPoint.UserOperation memory userOp)
    {
        userOp.sender = address(account);
        userOp.nonce = account.nonce();
        userOp.initCode = bytes("");
        userOp.callData = bytes("");
        userOp.callGasLimit = 100_000;
        userOp.verificationGasLimit = 100_000;
        userOp.preVerificationGas = 21_000;
        userOp.maxFeePerGas = 1_000_000_000;
        userOp.maxPriorityFeePerGas = 1_000_000_000;
        userOp.paymasterAndData = bytes("");
    }

    function test_Constructor() public {
        assertEq(account.owner(), owner);
        assertEq(address(account.entryPoint()), entryPoint);
    }

    function test_ValidateUserOp_Success() public {
        (
            IEntryPoint.UserOperation memory userOp,
            bytes32 userOpHash
        ) = makeUserOp(0);
        vm.prank(entryPoint);
        uint256 result = account.validateUserOp(userOp, userOpHash, 0);
        assertEq(result, 0);
    }

    function test_ValidateUserOp_InvalidNonce() public {
        (
            IEntryPoint.UserOperation memory userOp,
            bytes32 userOpHash
        ) = makeUserOp(1); // nonce should be 0
        vm.prank(entryPoint);
        vm.expectRevert();
        account.validateUserOp(userOp, userOpHash, 0);
    }

    function test_ValidateUserOp_InvalidSignature() public {
        (
            IEntryPoint.UserOperation memory userOp,
            bytes32 userOpHash
        ) = makeUserOp(0);
        // Corrupt the signature
        userOp.signature = hex"deadbeef";
        vm.prank(entryPoint);
        uint256 result = account.validateUserOp(userOp, userOpHash, 0);
        assertEq(result, 1); // SIG_VALIDATION_FAILED
    }

    function test_ValidateUserOp_MissingAccountFunds() public {
        IEntryPoint.UserOperation memory userOp = buildBasicUserOp();
        bytes32 userOpHash = getUserOpHash(userOp);
        userOp.signature = signUserOpHash(userOpHash);
        // Ensure the account has enough balance to pay missingAccountFunds
        vm.deal(address(account), 1 ether);
        uint256 missingAccountFunds = 0.01 ether;
        console.log(
            "Account balance before validateUserOp:",
            address(account).balance
        );
        assertEq(
            address(account).balance >= missingAccountFunds,
            true,
            "Account lacks prefund balance"
        );
        vm.prank(entryPoint);
        uint256 result = account.validateUserOp(
            userOp,
            userOpHash,
            missingAccountFunds
        );
        assertEq(result, 0);
    }

    function test_ValidateUserOp_WrongCaller() public {
        IEntryPoint.UserOperation memory userOp = buildBasicUserOp();
        bytes32 userOpHash = getUserOpHash(userOp);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, userOpHash);
        userOp.signature = abi.encodePacked(r, s, v);
        uint256 missingAccountFunds = 0;
        vm.expectRevert();
        vm.prank(user);
        account.validateUserOp(userOp, userOpHash, missingAccountFunds);
    }

    function makeUserOp(
        uint256 nonce
    )
        internal
        view
        returns (IEntryPoint.UserOperation memory userOp, bytes32 userOpHash)
    {
        userOp.sender = address(account);
        userOp.nonce = nonce;
        userOp.initCode = bytes("");
        userOp.callData = bytes("");
        userOp.callGasLimit = 100_000;
        userOp.verificationGasLimit = 100_000;
        userOp.preVerificationGas = 21_000;
        userOp.maxFeePerGas = 1_000_000_000;
        userOp.maxPriorityFeePerGas = 1_000_000_000;
        userOp.paymasterAndData = bytes("");
        userOpHash = getUserOpHash(userOp);
        userOp.signature = signUserOpHash(userOpHash);
    }

    function test_Execute_OnlyEntryPoint() public {
        address dest = address(0x789);
        uint256 value = 0;
        bytes memory func = "";
        vm.prank(user);
        vm.expectRevert();
        account.execute(dest, value, func);
    }

    function test_Execute_Success() public {
        // Deploy a contract that sets a flag
        FlagReceiver receiver = new FlagReceiver();
        bytes memory callData = abi.encodeWithSignature("setFlag()", "");
        vm.prank(entryPoint);
        account.execute(address(receiver), 0, callData);
        assertTrue(receiver.flag());
    }

    function test_Execute_RevertOnFailure() public {
        // Call a contract that always reverts
        Reverter reverter = new Reverter();
        bytes memory callData = "";
        vm.prank(entryPoint);
        vm.expectRevert();
        account.execute(address(reverter), 0, callData);
    }

    function test_ExecuteBatch_Success() public {
        FlagReceiver receiver1 = new FlagReceiver();
        FlagReceiver receiver2 = new FlagReceiver();
        address[] memory targets = new address[](2);
        targets[0] = address(receiver1);
        targets[1] = address(receiver2);
        uint256[] memory values = new uint256[](2);
        bytes[] memory datas = new bytes[](2);
        datas[0] = abi.encodeWithSignature("setFlag()", "");
        datas[1] = abi.encodeWithSignature("setFlag()", "");
        vm.prank(entryPoint);
        account.executeBatch(targets, values, datas);
        assertTrue(receiver1.flag());
        assertTrue(receiver2.flag());
    }

    function test_ExecuteBatch_RevertOnFailure() public {
        FlagReceiver receiver1 = new FlagReceiver();
        Reverter reverter = new Reverter();
        address[] memory targets = new address[](2);
        targets[0] = address(receiver1);
        targets[1] = address(reverter);
        uint256[] memory values = new uint256[](2);
        bytes[] memory datas = new bytes[](2);
        datas[0] = abi.encodeWithSignature("setFlag()", "");
        datas[1] = "";
        vm.prank(entryPoint);
        vm.expectRevert();
        account.executeBatch(targets, values, datas);
        assertTrue(!receiver1.flag()); // Should revert before setting flag
    }

    function test_ExecuteBatch_InvalidTarget() public {
        address[] memory targets = new address[](1);
        targets[0] = address(0);
        uint256[] memory values = new uint256[](1);
        bytes[] memory datas = new bytes[](1);
        datas[0] = "";
        vm.prank(entryPoint);
        vm.expectRevert();
        account.executeBatch(targets, values, datas);
    }

    function test_Withdraw_And_GetBalance() public {
        vm.deal(address(this), 1 ether);
        payable(address(account)).transfer(1 ether);
        assertEq(account.getBalance(), 1 ether);
        vm.prank(owner);
        account.withdraw(0.5 ether, payable(user));
        assertEq(account.getBalance(), 0.5 ether);
        assertEq(user.balance, 0.5 ether);
    }
}

/// @notice Helper contract that sets a flag when called
contract FlagReceiver {
    bool public flag;

    function setFlag() external {
        flag = true;
    }
}

/// @notice Helper contract that always reverts
contract Reverter {
    fallback() external payable {
        revert("Always fails");
    }
}
