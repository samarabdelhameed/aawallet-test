// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {SimpleAccount} from "../src/SimpleAccount.sol";

contract SimpleAccountTest is Test {
    SimpleAccount public account;
    address public owner = address(0x123);
    address public user = address(0x456);

    function setUp() public {
        account = new SimpleAccount(owner);
    }

    function test_Constructor() public {
        assertEq(account.owner(), owner);
    }

    function test_ValidateUserOp() public {
        bytes memory userOp = "";
        bytes32 userOpHash = bytes32(0);
        uint256 missingAccountFunds = 0;

        uint256 result = account.validateUserOp(
            userOp,
            userOpHash,
            missingAccountFunds
        );
        assertEq(result, 0);
    }

    function test_Execute_OnlyOwner() public {
        address dest = address(0x789);
        uint256 value = 0;
        bytes memory func = "";

        // Should fail when called by non-owner
        vm.prank(user);
        vm.expectRevert();
        account.execute(dest, value, func);
    }

    function test_Execute_Success() public {
        address dest = address(0x789);
        uint256 value = 0;
        bytes memory func = "";

        // Should succeed when called by owner
        vm.prank(owner);
        account.execute(dest, value, func);
    }
}
