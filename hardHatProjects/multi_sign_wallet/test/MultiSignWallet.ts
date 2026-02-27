import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import hre from "hardhat";
import { getAddress } from "ethers";
import { ethers } from "hardhat";
// import DeploySchoolManagementSystemt from "../ignition/modules/DeploySchoolManagementSystemt";

describe("MultiSign Wallet", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployMultiSignWallet() {
    // Contracts are deployed using the first signer/account by default
    const [owner, owner1, owner2, owner3] = await hre.ethers.getSigners();

    const MultiSignWallet = await hre.ethers.getContractFactory(
      "MultiSignWallet",
    );
    const multiSignWallet = await MultiSignWallet.deploy(
      owner1,
      owner2,
      owner3,
    );
    await multiSignWallet.waitForDeployment();
    const multiSignWalletAddress = await multiSignWallet.getAddress();

    return {
      multiSignWallet,
      owner,
      owner1,
      owner2,
      owner3,
    };
  }

  describe("Deployment", function () {
    it("CheckTransaction submissions", async function () {
      const { multiSignWallet } = await loadFixture(deployMultiSignWallet);
      const [owner, owner1, owner2, owner3, addr4] =
        await hre.ethers.getSigners();

      await multiSignWallet
        .connect(owner1)
        .submitTransaction(await addr4.getAddress(), ethers.parseEther("100"));

      expect(await multiSignWallet.nextTransactionId()).to.equal(1);

      const transaction = await multiSignWallet.transactionById(1);
      expect(transaction.to).to.equal(await addr4.getAddress());
      expect(transaction.value).to.equal(ethers.parseEther("100"));
      expect(transaction.executed).to.equal(false);
    });

    // it("should allow student registration and get all students", async function () {
    //   const [deployer, student1, student2] = await hre.ethers.getSigners();
    //   const { token, schoolManagementSystem } = await loadFixture(
    //     deploySchoolManagementSystem,
    //   );

    //   // mint some funds to address1
    //   await token
    //     .connect(deployer)
    //     .mint(await student1.getAddress(), ethers.parseEther("8000"));

    //   const student1Balance = await token.balanceOf(
    //     await student1.getAddress(),
    //   );
    //   expect(student1Balance).to.equal(ethers.parseEther("8000"));

    //   await token
    //     .connect(deployer)
    //     .mint(await student2.getAddress(), ethers.parseEther("2000"));

    //   const student2Balance = await token.balanceOf(
    //     await student2.getAddress(),
    //   );
    //   expect(student2Balance).to.equal(ethers.parseEther("2000"));

    //   // test student1 and student2 can register

    //   // first approve that the contract can spend the money "allowance"

    //   // student1 approves "5000" to the contract
    //   await token
    //     .connect(student1)
    //     .approve(
    //       await schoolManagementSystem.getAddress(),
    //       ethers.parseEther("5000"),
    //     );

    //   const contractAllowanceFromStudent1 = await token.allowance(
    //     await student1.getAddress(),
    //     await schoolManagementSystem.getAddress(),
    //   );
    //   expect(contractAllowanceFromStudent1).to.equal(ethers.parseEther("5000"));

    //   // student2 approves "2000" to the contract
    //   await token
    //     .connect(student2)
    //     .approve(
    //       await schoolManagementSystem.getAddress(),
    //       ethers.parseEther("2000"),
    //     );

    //   const contractAllowanceFromStudent2 = await token.allowance(
    //     await student2.getAddress(),
    //     await schoolManagementSystem.getAddress(),
    //   );
    //   expect(contractAllowanceFromStudent2).to.equal(ethers.parseEther("2000"));

    //   // register students
    //   const Student1_fees = ethers.parseEther("5000");

    //   await schoolManagementSystem
    //     .connect(student1)
    //     .registerStudent("Justice", 200);

    //   const studentData = await schoolManagementSystem.students(
    //     student1.address,
    //   );
    //   expect(studentData.name).to.equal("Justice");
    //   expect(studentData.feesPaid).to.equal(Student1_fees);
    //   expect(studentData.paymentStatus).to.equal(true);
    // });
  });
});
