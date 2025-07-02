// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {SimpleAccount} from "../src/SimpleAccount.sol";

/**
 * @title SimpleAccount Deployment Script
 * @dev Professional deployment script for SimpleAccount ERC-4337 implementation
 * @author Your Name
 * @notice Deploys SimpleAccount with proper logging and verification support
 */
contract SimpleAccountDeploy is Script {
    // Deployment configuration
    address public owner;
    address public entryPoint;
    SimpleAccount public account;

    // Deployment metadata
    uint256 public deploymentGas;
    uint256 public deploymentBlock;
    uint256 public chainId;

    /**
     * Sample verification command:
     * forge verify-contract --constructor-args $(cast abi-encode "constructor(address,address)" $OWNER $ENTRYPOINT) DEPLOYED_ADDRESS src/SimpleAccount.sol:SimpleAccount --chain-id 11155111 --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY
     */

    function setUp() public {
        // Load environment variables with validation
        owner = vm.envAddress("OWNER");
        entryPoint = vm.envAddress("ENTRYPOINT");
        require(owner != address(0), "Invalid owner address");
        require(entryPoint != address(0), "Invalid entryPoint address");
        chainId = block.chainid;
        deploymentBlock = block.number;
    }

    function run() external {
        console.log("Starting SimpleAccount deployment...");
        console.logUint(chainId);
        console.log("Owner address:");
        console.logAddress(owner);
        console.log("EntryPoint address:");
        console.logAddress(entryPoint);
        console.log("Current block:");
        console.logUint(deploymentBlock);

        vm.startBroadcast();
        uint256 gasBefore = gasleft();
        account = new SimpleAccount(owner, entryPoint);
        deploymentGas = gasBefore - gasleft();
        vm.stopBroadcast();

        console.log("SimpleAccount deployed at:");
        console.logAddress(address(account));
        console.log("Gas used:");
        console.logUint(deploymentGas);
        console.log("Deployment block:");
        console.logUint(deploymentBlock);

        // Log constructor arguments for verification
        console.log("Constructor args for verification:");
        console.logAddress(owner);
        console.logAddress(entryPoint);

        // Output verification command (see comment above for full example)
        console.log("Use the above addresses in your verification command.");

        _validateDeployment();
        console.log("Deployment completed successfully!");
    }

    /**
     * @dev Validates the deployed contract
     */
    function _validateDeployment() internal view {
        console.log("Validating deployment...");
        address deployedOwner = account.owner();
        require(deployedOwner == owner, "Owner mismatch");
        console.log("Owner validation passed");
        address deployedEntryPoint = address(account.entryPoint());
        require(deployedEntryPoint == entryPoint, "EntryPoint mismatch");
        console.log("EntryPoint validation passed");
        uint256 initialNonce = account.nonce();
        require(initialNonce == 0, "Initial nonce should be 0");
        console.log("Initial nonce validation passed");
        console.log("All validations passed!");
    }

    /**
     * @dev Returns deployment information for external use
     */
    function getDeploymentInfo()
        external
        view
        returns (
            address deployedAddress,
            address contractOwner,
            address contractEntryPoint,
            uint256 gasUsed,
            uint256 deployBlock,
            uint256 networkId
        )
    {
        return (
            address(account),
            owner,
            entryPoint,
            deploymentGas,
            deploymentBlock,
            chainId
        );
    }
}
