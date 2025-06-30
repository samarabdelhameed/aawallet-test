// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {AccountFactory} from "../src/AccountFactory.sol";

contract AccountFactoryDeploy is Script {
    function run() external {
        vm.startBroadcast();
        AccountFactory factory = new AccountFactory();
        console.log("AccountFactory deployed at:", address(factory));
        vm.stopBroadcast();
    }
}
