import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { ethers } from "hardhat";

export default buildModule("DeployModule", (m) => {
  const initialSupply = ethers.parseEther("1000");
  // Deploy ERC20
  const token = m.contract("ERC20", [
    "MyToken",
    "MTK",
    m.getParameter("initialSupply", initialSupply), // 1000 tokens
  ]);

  return { token };
});
