import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import hre from "hardhat";
import { getAddress } from "ethers";
import { ethers } from "hardhat";
// import DeploySchoolManagementSystemt from "../ignition/modules/DeploySchoolManagementSystemt";

describe("School Management System and SchoolToken(ERC20_token Standard)", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deploySchoolManagementSystem() {
    // Contracts are deployed using the first signer/account by default
    const [owner, user, student1, student2, staff1, staff2] =
      await hre.ethers.getSigners();
    const initialSupply = ethers.parseEther("1000");

    const SchoolToken = await hre.ethers.getContractFactory("SchoolToken");
    const token = await SchoolToken.deploy("SchoolToken", "STK", initialSupply);
    await token.waitForDeployment();
    const tokenAddress = await token.getAddress();

    const SchoolManagementSystem = await hre.ethers.getContractFactory(
      "SchoolManagementSystem",
    );
    const schoolManagementSystem = await SchoolManagementSystem.deploy(
      tokenAddress,
    );
    await schoolManagementSystem.waitForDeployment();
    const schoolManagementSystemAddress =
      await schoolManagementSystem.getAddress();

    return {
      token,
      schoolManagementSystem,
      owner,
      user,
      student1,
      student2,
      staff1,
      staff2,
    };
  }

  describe("Deployment", function () {
    it("Should return the name, the symbol and the token initial supply", async function () {
      const { token } = await loadFixture(deploySchoolManagementSystem);
      const initialSupply = ethers.parseEther("1000");

      expect(await token.name()).to.equal("SchoolToken");
      expect(await token.symbol()).to.equal("STK");
      expect(await token.totalSupply()).to.equal(initialSupply);
    });

    it("should allow student registration and get all students", async function () {
      const [deployer, student1, student2] = await hre.ethers.getSigners();
      const { token, schoolManagementSystem } = await loadFixture(
        deploySchoolManagementSystem,
      );

      // mint some funds to address1
      await token
        .connect(deployer)
        .mint(await student1.getAddress(), ethers.parseEther("8000"));

      const student1Balance = await token.balanceOf(
        await student1.getAddress(),
      );
      expect(student1Balance).to.equal(ethers.parseEther("8000"));

      await token
        .connect(deployer)
        .mint(await student2.getAddress(), ethers.parseEther("2000"));

      const student2Balance = await token.balanceOf(
        await student2.getAddress(),
      );
      expect(student2Balance).to.equal(ethers.parseEther("2000"));

      // test student1 and student2 can register

      // first approve that the contract can spend the money "allowance"

      // student1 approves "5000" to the contract
      await token
        .connect(student1)
        .approve(
          await schoolManagementSystem.getAddress(),
          ethers.parseEther("5000"),
        );

      const contractAllowanceFromStudent1 = await token.allowance(
        await student1.getAddress(),
        await schoolManagementSystem.getAddress(),
      );
      expect(contractAllowanceFromStudent1).to.equal(ethers.parseEther("5000"));

      // student2 approves "2000" to the contract
      await token
        .connect(student2)
        .approve(
          await schoolManagementSystem.getAddress(),
          ethers.parseEther("2000"),
        );

      const contractAllowanceFromStudent2 = await token.allowance(
        await student2.getAddress(),
        await schoolManagementSystem.getAddress(),
      );
      expect(contractAllowanceFromStudent2).to.equal(ethers.parseEther("2000"));

      // register students
      const Student1_fees = ethers.parseEther("5000");

      await schoolManagementSystem
        .connect(student1)
        .registerStudent("Justice", 200);

      const studentData = await schoolManagementSystem.students(
        student1.address,
      );
      expect(studentData.name).to.equal("Justice");
      expect(studentData.feesPaid).to.equal(Student1_fees);
      expect(studentData.paymentStatus).to.equal(true);
    });
  });

  describe("Staff registration & payment", function () {
    it("Owner can register staff and pay salary", async function () {
      const { token, schoolManagementSystem, owner, staff1 } =
        await loadFixture(deploySchoolManagementSystem);

      // owner can register staff
      const salary = ethers.parseEther("500");

      // funding contract to be able to pay fee
      await token.transfer(
        schoolManagementSystem.getAddress(),
        ethers.parseEther("1000"),
      );

      await schoolManagementSystem.registerStaff(
        staff1.getAddress(),
        "Ada",
        "Head Teacher",
        salary,
      );

      const staffData = await schoolManagementSystem.staffs(staff1.address);

      expect(staffData.name).to.equal("Ada");
      expect(staffData.salary).to.equal(salary);
      expect(staffData.paymentStatusForTheMonth).to.equal(false);
      expect(staffData.role).to.equal("Head Teacher");

      // Pay staff
      await hre.network.provider.send("evm_increaseTime", [29 * 24 * 60 * 60]); // making sure it's 29 days
      await schoolManagementSystem.payStaff(staff1.address);

      const updatedStaff = await schoolManagementSystem.staffs(staff1.address);
      expect(updatedStaff.totalPaymentReceived).to.equal(salary);
      expect(updatedStaff.status).to.equal(1);
    });
  });

  describe("Staff suspension toggle", function () {
    it("Should toggle staff suspension status", async function () {
      const { schoolManagementSystem, owner, staff1 } = await loadFixture(
        deploySchoolManagementSystem,
      );

      await schoolManagementSystem.registerStaff(
        staff1.address,
        "Bob",
        "Teacher",
        ethers.parseEther("500"),
      );

      let staffData = await schoolManagementSystem.staffs(staff1.address);
      expect(staffData.status).to.equal(0); // 0 - Probation

      await schoolManagementSystem.toogleSuspension(staff1.address);
      staffData = await schoolManagementSystem.staffs(staff1.address);
      expect(staffData.status).to.equal(2); // 2 - Suspended

      await schoolManagementSystem.toogleSuspension(staff1.address);
      staffData = await schoolManagementSystem.staffs(staff1.address);
      expect(staffData.status).to.equal(1); // 1 - Active
    });
  });

  it("Should return all students and staff", async function () {
    const { token, schoolManagementSystem, student1, student2, staff1 } =
      await loadFixture(deploySchoolManagementSystem);

    await token.mint(student1.address, ethers.parseEther("5000"));

    await token
      .connect(student1)
      .approve(schoolManagementSystem.getAddress(), ethers.parseEther("5000"));

    // Register student1
    await schoolManagementSystem
      .connect(student1)
      .registerStudent("Justice", 200);

    // Register staff
    await schoolManagementSystem.registerStaff(
      staff1.address,
      "Bob",
      "Teacher",
      ethers.parseEther("500"),
    );

    // Get all students and staff
    const students = await schoolManagementSystem.getAllStudents();
    const staffs = await schoolManagementSystem.getAllStaff();

    // check - must be true
    expect(students.length).to.equal(1); // registered only one student
    expect(students[0].name).to.equal("Justice");
    expect(students[0].studentAddress).to.equal(student1.address);

    expect(staffs.length).to.equal(1);
    expect(staffs[0].name).to.equal("Bob");
  });
});
