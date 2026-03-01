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

  //   Balance before swap
  const daiBefore = await DAI.balanceOf(signer.address);
  console.log("DAI before swap:", ethers.formatUnits(daiBefore, 18));

  const usdcBefore = await USDC.balanceOf(signer.address);
  console.log("USDC before swap:", ethers.formatUnits(usdcBefore, 6));

  // Swap Parameters
  const amountOut = ethers.parseUnits("1000", 18); // want 1000 DAI
  const amountinMax = ethers.parseUnits("1100", 6); // willing to spend at most 1100 USDC
  const path = [USDCAddress, DAIAddress]; // USDC → DAI
  const to = signer.address;
  const deadline = Math.floor(Date.now() / 1000) + 60 * 10; // 10 minutes from now

  await USDC.approve(UNIRouter, amountinMax);

  const transaction = await ROUTER.swapTokensForExactTokens(
    amountOut,
    amountinMax,
    path,
    to,
    deadline,
  );
  await transaction.wait();

  //   Balance after swap
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
