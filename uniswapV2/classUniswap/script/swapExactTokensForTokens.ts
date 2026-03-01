import { ethers } from "hardhat";
const helpers = require("@nomicfoundation/hardhat-network-helpers");

const main = async () => {
  // Addresses
  const UNIRouter = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";
  const DAIAddress = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
  const USDCAddress = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
  const USDCHolder = "0xf584f8728b874a6a5c7a8d4d387c9aae9172d621";

  // Impersonate account
  await helpers.impersonateAccount(USDCHolder);
  const signer = await ethers.getSigner(USDCHolder);

  // Contract instances
  const ROUTER = await ethers.getContractAt(
    "IUniswapV2Router",
    UNIRouter,
    signer,
  );
  const DAI = await ethers.getContractAt("IERC20", DAIAddress, signer);
  const USDC = await ethers.getContractAt("IERC20", USDCAddress, signer);

  // Swap Parameters
  const amountIn = ethers.parseUnits("100", 6); // want to swap 100 USDC
  const amountOutMin = ethers.parseUnits("90", 18); // willing to receive at least 90 DAI
  const path = [USDCAddress, DAIAddress]; // USDC → DAI
  const to = signer.address;
  const deadline = Math.floor(Date.now() / 1000) + 60 * 10; // 10 minutes from now

  await USDC.approve(UNIRouter, amountIn);
  // Optional: Check DAI and USDC balance before swap
  const daiBefore = await DAI.balanceOf(signer.address);
  console.log("DAI before swap:", ethers.formatUnits(daiBefore, 18));

  const usdcBefore = await USDC.balanceOf(signer.address);
  console.log("USDC before swap:", ethers.formatUnits(usdcBefore, 6));

  // Perform the swap
  const tx = await ROUTER.swapExactTokensForTokens(
    amountIn,
    amountOutMin,
    path,
    to,
    deadline,
  );
  await tx.wait();

  // Check DAI and USDC balance after swap
  const daiAfter = await DAI.balanceOf(signer.address);
  console.log("DAI after swap:", ethers.formatUnits(daiAfter, 18));
  console.log("DAI received:", ethers.formatUnits(daiAfter - daiBefore, 18));

  const usdcAfter = await USDC.balanceOf(signer.address);
  console.log("USDC after swap:", ethers.formatUnits(usdcAfter, 6));
  console.log("USDC spent:", ethers.formatUnits(usdcBefore - usdcAfter, 6));
};

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
