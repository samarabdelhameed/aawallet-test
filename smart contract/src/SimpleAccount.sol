// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleAccount {
    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }

    function validateUserOp(
        bytes calldata userOp,
        bytes32 userOpHash,
        uint256 missingAccountFunds
    ) external pure returns (uint256) {
        return 0;
    }

    function execute(
        address dest,
        uint256 value,
        bytes calldata func
    ) external {
        require(msg.sender == owner);
        (bool success, ) = dest.call{value: value}(func);
        require(success);
    }
}
