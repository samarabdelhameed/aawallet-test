// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IEntryPoint} from "./IEntryPoint.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract SimpleAccount {
    address public owner;
    address public entryPoint;
    uint256 public nonce;

    constructor(address _owner, address _entryPoint) {
        owner = _owner;
        entryPoint = _entryPoint;
        nonce = 0;
    }

    function validateUserOp(
        IEntryPoint.UserOperation calldata userOp,
        bytes32 userOpHash,
        uint256 /* missingAccountFunds */
    ) external returns (uint256) {
        require(msg.sender == entryPoint, "Not EntryPoint");
        require(userOp.nonce == nonce, "Invalid nonce");
        // Verify signature
        address recovered = ECDSA.recover(userOpHash, userOp.signature);
        require(recovered == owner, "Invalid signature");
        nonce++;
        return 0;
    }

    function execute(
        address dest,
        uint256 value,
        bytes calldata func
    ) external {
        require(msg.sender == entryPoint, "Not EntryPoint");
        (bool success, ) = dest.call{value: value}(func);
        require(success, "Call failed");
    }
}
