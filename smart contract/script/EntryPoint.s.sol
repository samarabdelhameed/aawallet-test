// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {EntryPoint} from "../src/EntryPoint.sol";

contract EntryPointDeploy is Script {
    function run() external {
        vm.startBroadcast();
        EntryPoint entryPoint = new EntryPoint();
        console.log("EntryPoint deployed at:", address(entryPoint));
        vm.stopBroadcast();
    }
}
