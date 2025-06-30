// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {EntryPoint} from "../src/EntryPoint.sol";
import {IEntryPoint} from "../src/IEntryPoint.sol";
import {SimpleAccount} from "../src/SimpleAccount.sol";

contract EntryPointProfessionalTest is Test {
    EntryPoint public entryPoint;
    SimpleAccount public account;
    address public beneficiary = address(0xBEEF);
    uint256 private ownerPrivateKey = 0x123;
    address public owner;

    function setUp() public {
        entryPoint = new EntryPoint();
        owner = vm.addr(ownerPrivateKey);
        account = new SimpleAccount(owner, address(entryPoint));
    }

    function _packUserOp(
        IEntryPoint.UserOperation memory op
    ) internal pure returns (bytes memory) {
        return
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
            );
    }

    function test_HandleOps_Minimal() public {
        IEntryPoint.UserOperation memory userOp;
        userOp.sender = address(account);
        userOp.nonce = 0;
        userOp.initCode = bytes("");
        userOp.callData = bytes("");
        userOp.callGasLimit = 100000;
        userOp.verificationGasLimit = 100000;
        userOp.preVerificationGas = 21000;
        userOp.maxFeePerGas = 1_000_000_000;
        userOp.maxPriorityFeePerGas = 1_000_000_000;
        userOp.paymasterAndData = bytes("");
        // Compute userOpHash in a professional, ERC-4337-compliant way
        bytes32 userOpHash = keccak256(_packUserOp(userOp));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, userOpHash);
        userOp.signature = abi.encodePacked(r, s, v);
        IEntryPoint.UserOperation[]
            memory ops = new IEntryPoint.UserOperation[](1);
        ops[0] = userOp;
        entryPoint.handleOps(ops, payable(beneficiary));
    }
}
