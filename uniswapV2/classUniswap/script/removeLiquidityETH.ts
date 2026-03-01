import { ethers } from "hardhat";
const helpers = require("@nomicfoundation/hardhat-network-helpers");

const main = async () => {
  const UNIRouter = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";
  const USDCAddress = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
  const USDCWETHPairAddress = "0xb4e16d0168e52d35cacd2c6185b44281ec28c9dc";
  const USDCHolder = "0xf584f8728b874a6a5c7a8d4d387c9aae9172d621";

  await helpers.impersonateAccount(USDCHolder);
  await helpers.setBalance(USDCHolder, ethers.parseEther("10"));
  const signer = await ethers.getSigner(USDCHolder);

  console.log("Impersonating:", signer.address);

  const ROUTER = await ethers.getContractAt(
    "IUniswapV2Router",
    UNIRouter,
    signer,
  );

  const USDC = await ethers.getContractAt("IERC20", USDCAddress, signer);

  const LPToken = await ethers.getContractAt(
    "IERC20",
    USDCWETHPairAddress,
    signer,
  );

  // ========= ADD LIQUIDITY =========
  const amountTokenDesired = ethers.parseUnits("400", 6); // 400 USDC
  const amountTokenMin = ethers.parseUnits("390", 6);
  const amountETHMin = ethers.parseEther("0.05");
  const amountETHDesired = ethers.parseEther("0.2");

  const deadline = Math.floor(Date.now() / 1000) + 60 * 10;

  await USDC.approve(UNIRouter, amountTokenDesired);

  console.log("...Adding liquidity");

  const addTx = await ROUTER.addLiquidityETH(
    USDCAddress,
    amountTokenDesired,
    amountTokenMin,
    amountETHMin,
    signer.address,
    deadline,
    { value: amountETHDesired },
  );

  await addTx.wait();

  console.log("Liquidity added....... Now removing liquidity");

  // CHECK LP BALANCE
  const lpBalBefore = await LPToken.balanceOf(signer.address);

  console.log("LP Tokens received:", ethers.formatUnits(lpBalBefore, 18));

  const liquidityToRemove = lpBalBefore / 2n;

  // REMOVE LIQUIDITY
  await LPToken.approve(UNIRouter, liquidityToRemove);

  const usdcBalBefore = await USDC.balanceOf(signer.address);

  const ethBalBefore = await ethers.provider.getBalance(signer.address);

  console.log("Removing liquidity...");

  const removeTx = await ROUTER.removeLiquidityETH(
    USDCAddress,
    liquidityToRemove,
    ethers.parseUnits("1", 6), // min USDC
    ethers.parseEther("0.001"), // min ETH
    signer.address,
    deadline,
  );

  await removeTx.wait();

  console.log("Liquidity removed....... Checking balances");

  // CHECK BALANCES AFTER
  const usdcBalAfter = await USDC.balanceOf(signer.address);

  const ethBalAfter = await ethers.provider.getBalance(signer.address);

  const lpBalAfter = await LPToken.balanceOf(signer.address);

  console.log(
    "USDC received:",
    ethers.formatUnits(usdcBalAfter - usdcBalBefore, 6),
  );

  console.log(
    "ETH received (minus gas):",
    ethers.formatEther(ethBalAfter - ethBalBefore),
  );

  console.log("LP burned:", ethers.formatUnits(lpBalBefore - lpBalAfter, 18));
};

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
