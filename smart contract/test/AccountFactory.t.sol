// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {AccountFactory} from "../src/AccountFactory.sol";
import {SimpleAccount} from "../src/SimpleAccount.sol";

contract AccountFactoryTest is Test {
    AccountFactory public factory;
    address public owner = address(0x123);
    address public entryPoint = address(0x456);

    function setUp() public {
        factory = new AccountFactory();
    }

    function test_CreateAccount() public {
        address accountAddr = factory.createAccount(owner, entryPoint);
        assertTrue(
            accountAddr != address(0),
            "Account address should not be zero"
        );
        SimpleAccount account = SimpleAccount(accountAddr);
        assertEq(account.owner(), owner);
        assertEq(account.entryPoint(), entryPoint);
    }
}
