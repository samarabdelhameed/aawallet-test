// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EntryPoint {
    event UserOperationHandled(address sender, address target);

    function handleOps(
        address account,
        address dest,
        uint256 value,
        bytes calldata func
    ) external {
        (bool success, ) = account.call(
            abi.encodeWithSignature(
                "execute(address,uint256,bytes)",
                dest,
                value,
                func
            )
        );
        require(success, "UserOp failed");
        emit UserOperationHandled(msg.sender, dest);
    }
}
