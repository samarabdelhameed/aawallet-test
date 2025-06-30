// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {SimpleAccount} from "../src/SimpleAccount.sol";
import {EntryPoint} from "../src/EntryPoint.sol";
import {IEntryPoint} from "../src/IEntryPoint.sol";

contract EntryPointTest is Test {
    SimpleAccount public account;
    EntryPoint public entryPoint;
    address public owner = address(0x123);
    address public user = address(0x456);

    function setUp() public {
        entryPoint = new EntryPoint();
        account = new SimpleAccount(owner, address(entryPoint));
    }

    function test_HandleOps_Execute() public {
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
        userOp.signature = bytes("");
        IEntryPoint.UserOperation[]
            memory ops = new IEntryPoint.UserOperation[](1);
        ops[0] = userOp;
        entryPoint.handleOps(ops, payable(owner));
    }
}
