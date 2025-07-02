// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IEntryPoint} from "./IEntryPoint.sol";

interface ISimpleAccount {
    function validateUserOp(
        IEntryPoint.UserOperation calldata userOp,
        bytes32 userOpHash,
        uint256 missingAccountFunds
    ) external returns (uint256);
}
