// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {SimpleAccount} from "../src/SimpleAccount.sol";
import {EntryPoint} from "../src/EntryPoint.sol";

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
        // سنرسل عملية تنفيذ (UserOperation) من خلال EntryPoint
        address dest = address(0x789);
        uint256 value = 0;
        bytes memory func = "";
        // يجب أن تنجح العملية بدون revert
        entryPoint.handleOps(address(account), dest, value, func);
    }
}
