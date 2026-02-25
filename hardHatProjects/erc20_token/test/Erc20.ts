import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import hre from "hardhat";
import { getAddress } from "ethers";
import { ethers } from "hardhat";
import DeployErc20 from "../ignition/modules/DeployErc20";

describe("ERC20 Token", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployErc20() {
    // Contracts are deployed using the first signer/account by default
    const [owner, user, spender, account1] = await hre.ethers.getSigners();
    const initialSupply = ethers.parseEther("1000");

    const ERC20 = await hre.ethers.getContractFactory("ERC20");
    const token = await ERC20.deploy("MyToken", "MTK", initialSupply);
    await token.waitForDeployment();
    const tokenAddress = await token.getAddress();

    return { token, user, spender, account1 };
  }

  describe("Deployment", function () {
    it("Should return the name, the symbol and the token initial supply", async function () {
      const { token } = await loadFixture(deployErc20);
      const initialSupply = ethers.parseEther("1000");

      expect(await token.name()).to.equal("MyToken");
      expect(await token.symbol()).to.equal("MTK");
      expect(await token.totalSupply()).to.equal(initialSupply);
      expect(await token.decimals()).to.equal(18);
    });

    it("Should approve token, allow deposit, transfer from, mint, burn, check allowance and get user balance", async function () {
      const [deployer, user, spender, account1, accountToMint] =
        await hre.ethers.getSigners();
      const { token } = await loadFixture(deployErc20);

      const amountToSpend = ethers.parseEther("100");
      const amountSpent = ethers.parseEther("50");
      const burnAmount = ethers.parseEther("50");

      await token.transfer(user.address, ethers.parseEther("200"));

      const balanceOfUSer = await token.balanceOf(user.address);
      expect(balanceOfUSer).to.equal(ethers.parseEther("200"));

      await token
        .connect(user)
        .approve(await spender.getAddress(), amountToSpend);

      const allowance = await token.allowance(
        await user.getAddress(),
        await spender.getAddress(),
      );

      expect(allowance).to.equal(amountToSpend);

      // transfer from
      await token
        .connect(spender)
        .transferFrom(
          await user.getAddress(),
          await account1.getAddress(),
          amountSpent,
        );

      const balanceOfAccount1 = await token.balanceOf(account1.address);
      expect(balanceOfAccount1).to.equal(ethers.parseEther("50"));

      // mint
      await token
        .connect(deployer)
        .mint(await accountToMint.getAddress(), ethers.parseEther("100"));

      const balanceOfAccountToMint = await token.balanceOf(
        accountToMint.address,
      );
      expect(balanceOfAccountToMint).to.equal(ethers.parseEther("100"));

      // burn token
      const initialBalance = await token.balanceOf(deployer.getAddress());
      const initialSupply = await token.totalSupply();
      await token.connect(deployer).burn(burnAmount);

      const finalBalance = await token.balanceOf(deployer.getAddress());
      const finalSupply = await token.totalSupply();

      expect(finalBalance).to.equal(initialBalance - burnAmount);
      expect(finalSupply).to.equal(initialSupply - burnAmount);
    });
  });
});
