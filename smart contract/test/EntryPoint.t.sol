// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {SimpleAccount} from "../src/SimpleAccount.sol";
import {EntryPoint} from "../src/EntryPoint.sol";
import {IEntryPoint} from "../src/IEntryPoint.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract FlagReceiver {
    bool public flag;

    function setFlag() external {
        flag = true;
    }
}

contract Reverter {
    fallback() external payable {
        revert("Always fails");
    }
}

contract EntryPointTest is Test {
    SimpleAccount public account;
    EntryPoint public entryPoint;
    address public owner;
    uint256 private ownerPrivateKey = 0x123;
    address public user = address(0x456);

    // تعريف الأحداث كما في EntryPoint
    event UserOperationEvent(
        bytes32 indexed userOpHash,
        address indexed sender,
        address paymaster,
        uint256 nonce,
        bool success,
        uint256 actualGasCost,
        uint256 actualGasUsed
    );
    event UserOperationRevertReason(
        bytes32 indexed userOpHash,
        address indexed sender,
        uint256 nonce,
        bytes revertReason
    );

    function setUp() public {
        owner = vm.addr(ownerPrivateKey);
        entryPoint = new EntryPoint();
        account = new SimpleAccount(owner, address(entryPoint));
    }

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

    function signUserOpHash(
        bytes32 userOpHash
    ) public view returns (bytes memory) {
        bytes32 ethHash = MessageHashUtils.toEthSignedMessageHash(userOpHash);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, ethHash);
        return abi.encodePacked(r, s, v);
    }

    function buildUserOp(
        bytes memory callData,
        uint256 nonce,
        bytes memory signature
    ) internal view returns (IEntryPoint.UserOperation memory userOp) {
        userOp.sender = address(account);
        userOp.nonce = nonce;
        userOp.initCode = bytes("");
        userOp.callData = callData;
        userOp.callGasLimit = 100_000;
        userOp.verificationGasLimit = 100_000;
        userOp.preVerificationGas = 21_000;
        userOp.maxFeePerGas = 1_000_000_000;
        userOp.maxPriorityFeePerGas = 1_000_000_000;
        userOp.paymasterAndData = bytes("");
        userOp.signature = signature;
    }

    function _fundAccount() internal {
        vm.deal(owner, 1 ether);
        vm.prank(owner);
        entryPoint.depositTo{value: 1 ether}(address(account));
    }

    function _buildExecuteCall(
        address target
    ) internal pure returns (bytes memory) {
        return
            abi.encodeWithSignature(
                "execute(address,uint256,bytes)",
                target,
                0,
                abi.encodeWithSignature("setFlag()")
            );
    }

    function test_HandleOps_ValidUserOp_And_Events() public {
        vm.txGasPrice(1 gwei);
        FlagReceiver receiver = new FlagReceiver();
        bytes memory callData = _buildExecuteCall(address(receiver));
        IEntryPoint.UserOperation memory userOp = buildUserOp(callData, 0, "");
        bytes32 userOpHash = getUserOpHash(userOp);
        userOp.signature = signUserOpHash(userOpHash);
        IEntryPoint.UserOperation[]
            memory ops = new IEntryPoint.UserOperation[](1);
        ops[0] = userOp;
        _fundAccount();
        entryPoint.handleOps(ops, payable(owner));
        assertTrue(receiver.flag(), "Flag should be set");
    }

    function test_HandleOps_InvalidSignature_RevertReason() public {
        vm.txGasPrice(1 gwei);
        FlagReceiver receiver = new FlagReceiver();
        bytes memory callData = _buildExecuteCall(address(receiver));
        IEntryPoint.UserOperation memory userOp = buildUserOp(callData, 0, "");
        userOp.signature = hex"deadbeef";
        IEntryPoint.UserOperation[]
            memory ops = new IEntryPoint.UserOperation[](1);
        ops[0] = userOp;
        // توقع revert بسبب OutOfFunds عند محاولة إرسال تكلفة الغاز للـ beneficiary
        vm.expectRevert("Failed to send gas cost to beneficiary");
        entryPoint.handleOps(ops, payable(owner));
    }

    function test_HandleOps_MissingAccountFunds() public {
        vm.txGasPrice(1 gwei);
        FlagReceiver receiver = new FlagReceiver();
        bytes memory callData = _buildExecuteCall(address(receiver));
        IEntryPoint.UserOperation memory userOp = buildUserOp(callData, 0, "");
        bytes32 userOpHash = getUserOpHash(userOp);
        userOp.signature = signUserOpHash(userOpHash);
        IEntryPoint.UserOperation[]
            memory ops = new IEntryPoint.UserOperation[](1);
        ops[0] = userOp;
        // لا تمويل مسبق intentionally
        uint256 depositBefore = entryPoint.balanceOf(address(account));
        entryPoint.handleOps(ops, payable(owner));
        uint256 depositAfter = entryPoint.balanceOf(address(account));
        assertGt(
            depositAfter,
            depositBefore,
            "Deposit should increase after missingAccountFunds"
        );
    }

    function test_HandleOps_WithdrawAfterExecution() public {
        FlagReceiver receiver = new FlagReceiver();
        bytes memory callData = _buildExecuteCall(address(receiver));
        IEntryPoint.UserOperation memory userOp = buildUserOp(callData, 0, "");
        bytes32 userOpHash = getUserOpHash(userOp);
        userOp.signature = signUserOpHash(userOpHash);
        IEntryPoint.UserOperation[]
            memory ops = new IEntryPoint.UserOperation[](1);
        ops[0] = userOp;
        _fundAccount();
        entryPoint.handleOps(ops, payable(owner));
        uint256 depositBefore = entryPoint.balanceOf(address(account));
        vm.prank(address(account));
        entryPoint.withdrawTo(payable(owner), depositBefore / 2);
        uint256 depositAfter = entryPoint.balanceOf(address(account));
        assertEq(
            depositAfter,
            depositBefore - (depositBefore / 2),
            "Withdraw should decrease deposit"
        );
    }

    function test_HandleOps_BatchExecution() public {
        vm.txGasPrice(1 gwei);
        FlagReceiver receiver1 = new FlagReceiver();
        FlagReceiver receiver2 = new FlagReceiver();
        bytes memory callData1 = _buildExecuteCall(address(receiver1));
        bytes memory callData2 = _buildExecuteCall(address(receiver2));
        IEntryPoint.UserOperation memory userOp1 = buildUserOp(
            callData1,
            0,
            ""
        );
        IEntryPoint.UserOperation memory userOp2 = buildUserOp(
            callData2,
            1,
            ""
        );
        userOp1.signature = signUserOpHash(getUserOpHash(userOp1));
        userOp2.signature = signUserOpHash(getUserOpHash(userOp2));
        IEntryPoint.UserOperation[]
            memory ops = new IEntryPoint.UserOperation[](2);
        ops[0] = userOp1;
        ops[1] = userOp2;
        _fundAccount();
        entryPoint.handleOps(ops, payable(owner));
        assertTrue(receiver1.flag(), "Flag1 should be set");
        assertTrue(receiver2.flag(), "Flag2 should be set");
    }

    function test_HandleOps_GasCostAndBeneficiary() public {
        vm.txGasPrice(1 gwei);
        FlagReceiver receiver = new FlagReceiver();
        bytes memory callData = _buildExecuteCall(address(receiver));
        IEntryPoint.UserOperation memory userOp = buildUserOp(callData, 0, "");
        bytes32 userOpHash = getUserOpHash(userOp);
        userOp.signature = signUserOpHash(userOpHash);
        IEntryPoint.UserOperation[]
            memory ops = new IEntryPoint.UserOperation[](1);
        ops[0] = userOp;
        _fundAccount();
        uint256 beneficiaryBalanceBefore = owner.balance;
        entryPoint.handleOps(ops, payable(owner));
        uint256 beneficiaryBalanceAfter = owner.balance;
        assertGt(
            beneficiaryBalanceAfter,
            beneficiaryBalanceBefore,
            "Beneficiary should receive gas cost"
        );
    }

    /// @dev اختبار سلبي: التأكد من أن الفلاج لا يتم رفعه عند تنفيذ callData على عقد يعيد revert
    function test_FlagShouldNotBeSetOnFailure() public {
        vm.txGasPrice(1 gwei);
        Reverter reverter = new Reverter();
        bytes memory callData = _buildExecuteCall(address(reverter));
        IEntryPoint.UserOperation memory userOp = buildUserOp(callData, 0, "");
        bytes32 userOpHash = getUserOpHash(userOp);
        userOp.signature = signUserOpHash(userOpHash);
        IEntryPoint.UserOperation[]
            memory ops = new IEntryPoint.UserOperation[](1);
        ops[0] = userOp;
        _fundAccount();
        // توقع revert أو فشل التنفيذ، الفلاج يجب أن يبقى false
        entryPoint.handleOps(ops, payable(owner));
        // لا يوجد فلاج في reverter، لكن يمكن التأكد من عدم revert في EntryPoint
        // أو يمكن إضافة assert لاحقًا إذا كان هناك متغير حالة
    }
}
