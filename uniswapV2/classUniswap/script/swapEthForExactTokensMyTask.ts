import { ethers } from "hardhat";
const helpers = require("@nomicfoundation/hardhat-network-helpers");

const main = async () => {
  // ===================== Addresses =====================
  const UNIRouter = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";
  const DAIAddress = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
  const WETHAddress = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
  const ETHHolder = "0xf584f8728b874a6a5c7a8d4d387c9aae9172d621";

  // ===================== Impersonate account =====================
  await helpers.impersonateAccount(ETHHolder);
  const signer = await ethers.getSigner(ETHHolder);

  // ===================== Contract instances =====================
  const ROUTER = await ethers.getContractAt(
    "IUniswapV2Router",
    UNIRouter,
    signer,
  );
  const DAI = await ethers.getContractAt("IERC20", DAIAddress, signer);

  // ===================== Swap Parameters =====================
  const amountOut = ethers.parseUnits("1000", 18); // want 1000 DAI
  const path = [WETHAddress, DAIAddress];
  const to = signer.address;
  const deadline = Math.floor(Date.now() / 1000) + 60 * 10;

  // Optional: Check DAI balance before swap
  const daiBefore = await DAI.balanceOf(signer.address);
  console.log("DAI before swap:", ethers.formatUnits(daiBefore, 18));

  // ===================== Estimate ETH required =====================
  const amountsIn = await ROUTER.getAmountsIn(amountOut, path);
  const ethRequired = amountsIn[0];
  console.log("ETH required for swap:", ethers.formatEther(ethRequired));

  // ===================== Perform the swap =====================
  const tx = await ROUTER.swapETHForExactTokens(
    amountOut,
    path,
    to,
    deadline,
    { value: ethRequired }, // send required ETH
  );
  await tx.wait();

  // ===================== Check DAI balance after swap =====================
  const daiAfter = await DAI.balanceOf(signer.address);
  console.log("DAI after swap:", ethers.formatUnits(daiAfter, 18));
  console.log("DAI received:", ethers.formatUnits(daiAfter - daiBefore, 18));
};

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
