// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SimpleAccount} from "./SimpleAccount.sol";

contract AccountFactory {
    event AccountCreated(
        address indexed account,
        address indexed owner,
        address indexed entryPoint,
        uint256 salt
    );

    function createAccount(
        address owner,
        address entryPoint,
        uint256 salt
    ) public returns (address account) {
        account = getAddress(owner, entryPoint, salt);
        if (account.code.length > 0) {
            return account;
        }
        bytes memory bytecode = getBytecode(owner, entryPoint);
        assembly {
            account := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
            if iszero(account) {
                revert(0, 0)
            }
        }
        emit AccountCreated(account, owner, entryPoint, salt);
    }

    function getAddress(
        address owner,
        address entryPoint,
        uint256 salt
    ) public view returns (address) {
        bytes memory bytecode = getBytecode(owner, entryPoint);
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                salt,
                keccak256(bytecode)
            )
        );
        return address(uint160(uint256(hash)));
    }

    function getBytecode(
        address owner,
        address entryPoint
    ) public pure returns (bytes memory) {
        return
            abi.encodePacked(
                type(SimpleAccount).creationCode,
                abi.encode(owner, entryPoint)
            );
    }
}
