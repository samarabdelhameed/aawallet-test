// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SimpleAccount} from "./SimpleAccount.sol";

contract AccountFactory {
    event AccountCreated(
        address indexed account,
        address indexed owner,
        address indexed entryPoint
    );

    function createAccount(
        address owner,
        address entryPoint
    ) external returns (address) {
        SimpleAccount account = new SimpleAccount(owner, entryPoint);
        emit AccountCreated(address(account), owner, entryPoint);
        return address(account);
    }
}
