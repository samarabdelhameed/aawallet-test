// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {SimpleAccount} from "../src/SimpleAccount.sol";

contract SimpleAccountDeploy is Script {
    function run() external {
        address owner = vm.envAddress("OWNER");
        address entryPoint = vm.envAddress("ENTRYPOINT");
        vm.startBroadcast();
        SimpleAccount account = new SimpleAccount(owner, entryPoint);
        console.log("SimpleAccount deployed at:", address(account));
        vm.stopBroadcast();
    }
}
