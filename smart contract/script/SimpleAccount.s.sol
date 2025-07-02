// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {SimpleAccount} from "../src/SimpleAccount.sol";

/**
 * @title SimpleAccount Deployment Script
 * @dev Professional deployment script for SimpleAccount ERC-4337 implementation
 * @notice Deploys SimpleAccount with environment variables for owner and entryPoint
 */
contract SimpleAccountScript is Script {
    SimpleAccount public account;

    // Deployment configuration from environment
    address public owner;
    address public entryPoint;

    function setUp() public {
        // Load environment variables
        owner = vm.envAddress("OWNER");
        entryPoint = vm.envAddress("ENTRYPOINT");

        // Validate addresses
        require(owner != address(0), "Invalid owner address");
        require(entryPoint != address(0), "Invalid entryPoint address");

        console.log("Deployment Configuration:");
        console.log("Owner:");
        console.logAddress(owner);
        console.log("EntryPoint:");
        console.logAddress(entryPoint);
    }

    function run() public {
        console.log("Starting SimpleAccount deployment...");

        vm.startBroadcast();

        // Deploy SimpleAccount with owner and entryPoint from environment
        account = new SimpleAccount(owner, entryPoint);

        vm.stopBroadcast();

        // Log deployment results
        console.log("SimpleAccount deployed successfully!");
        console.log("Contract address:");
        console.logAddress(address(account));

        // Validate deployment
        _validateDeployment();

        console.log("Deployment completed successfully!");
    }

    /**
     * @dev Validates the deployed contract configuration
     */
    function _validateDeployment() internal view {
        console.log("Validating deployment...");

        // Check owner
        address deployedOwner = account.owner();
        require(deployedOwner == owner, "Owner mismatch");
        console.log("Owner validation passed");

        // Check entryPoint
        address deployedEntryPoint = address(account.entryPoint());
        require(deployedEntryPoint == entryPoint, "EntryPoint mismatch");
        console.log("EntryPoint validation passed");

        // Check initial nonce
        uint256 initialNonce = account.nonce();
        require(initialNonce == 0, "Initial nonce should be 0");
        console.log("Initial nonce validation passed");

        console.log("All validations passed!");
    }
}
