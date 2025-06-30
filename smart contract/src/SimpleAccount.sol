// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IEntryPoint {
    // EntryPoint interface functions can be added here
}

contract SimpleAccount {
    address public owner;
    address public entryPoint;

    constructor(address _owner, address _entryPoint) {
        owner = _owner;
        entryPoint = _entryPoint;
    }

    function validateUserOp(
        bytes calldata _userOp,
        bytes32 _userOpHash,
        uint256 _missingAccountFunds
    ) external pure returns (uint256) {
        // Unused parameters - prefixed with underscore to suppress warnings
        _userOp;
        _userOpHash;
        _missingAccountFunds;
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
