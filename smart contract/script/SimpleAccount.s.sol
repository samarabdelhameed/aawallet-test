// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {SimpleAccount} from "../src/SimpleAccount.sol";

contract SimpleAccountScript is Script {
    SimpleAccount public account;

    function setUp() public {}

    function run() public {
        // Get the deployer address
        address deployer = vm.addr(vm.envUint("PRIVATE_KEY"));

        vm.startBroadcast();

        // Deploy the SimpleAccount with the deployer as owner
        account = new SimpleAccount(deployer);

        console.log("SimpleAccount deployed at:", address(account));
        console.log("Owner set to:", deployer);

        vm.stopBroadcast();
    }
}
