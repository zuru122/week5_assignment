import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import hre from "hardhat";
import { getAddress } from "ethers";
import { ethers } from "hardhat";
import DeploySaveAsset from "../ignition/modules/DeploySaveAsset";

describe("ERC20 Token and Save Asset", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deploySaveAsset() {
    // Contracts are deployed using the first signer/account by default
    const [owner, user, account1] = await hre.ethers.getSigners();
    const initialSupply = ethers.parseEther("1000");

    const ERC20 = await hre.ethers.getContractFactory("ERC20");
    const token = await ERC20.deploy("MyToken", "MTK", initialSupply);
    await token.waitForDeployment();
    const tokenAddress = await token.getAddress();

    const SaveAsset = await hre.ethers.getContractFactory("SaveAsset");
    const saveAsset = await SaveAsset.deploy(tokenAddress);
    await saveAsset.waitForDeployment();
    const saveAssetAddress = await saveAsset.getAddress();

    return { token, saveAsset, owner, user, account1 };
  }

  describe("Deployment", function () {
    it("Should return the name, the symbol and the token initial supply", async function () {
      const { token } = await loadFixture(deploySaveAsset);
      const initialSupply = ethers.parseEther("1000");

      expect(await token.name()).to.equal("MyToken");
      expect(await token.symbol()).to.equal("MTK");
      expect(await token.totalSupply()).to.equal(initialSupply);
    });

    it("Should approve SaveAsset, allow deposit and getToken Balance", async function () {
      const [user] = await hre.ethers.getSigners();
      const { token, saveAsset } = await loadFixture(deploySaveAsset);

      const amountToSpend = ethers.parseEther("100");

      await token.transfer(user.address, ethers.parseEther("200"));

      const balanceAfterAllowance = ethers.parseEther("100");
      const withdrawTokenAmount = ethers.parseEther("50");

      await token
        .connect(user)
        .approve(await saveAsset.getAddress(), amountToSpend);

      const allowance = await token.allowance(
        user.address,
        await saveAsset.getAddress(),
      );

      expect(allowance).to.equal(amountToSpend);

      await saveAsset.connect(user).depositToken(amountToSpend);

      const contractBalance = await token.balanceOf(
        await saveAsset.getAddress(),
      );
      expect(contractBalance).to.equal(amountToSpend);

      const userBalance = await saveAsset.connect(user).getTokenBalance();
      expect(userBalance).to.equal(balanceAfterAllowance);

      await saveAsset.connect(user).withdrawToken(withdrawTokenAmount);
      expect(await token.balanceOf(await saveAsset.getAddress())).to.equal(
        withdrawTokenAmount,
      );

      expect(await saveAsset.tokenBalances(user.address)).to.equal(
        ethers.parseEther("50"),
      );
    });
  });
});
