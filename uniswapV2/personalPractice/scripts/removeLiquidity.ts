import { ethers } from "hardhat";
const helpers = require("@nomicfoundation/hardhat-network-helpers");

const main = async () => {
  // get address
  // threshold and shiba-inu

  const THRESHOLDAddress = "0xCdF7028ceAB81fA0C6971208e83fa7872994beE5";
  const SHIBAINUAddress = "0x95aD61b0a150d79219dCF64E1E6Cc01f0B64C4cE";
  const UNIRouterAddress = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";

  const impersonatorAddress = "0xf584F8728B874a6a5c7A8d4d387C9aae9172D621";

  //   Giving some eth to impersonator address incase my impersonator address do not have some eth
  // await helpers.setBalance(impersonatorAddress, ethers.parseEther("10"));

  //   signer
  await helpers.impersonateAccount(impersonatorAddress);
  const signer = await ethers.getSigner(impersonatorAddress);

  //   create instances
  const THRESHOLDContract = await ethers.getContractAt(
    "IERC20",
    THRESHOLDAddress,
    signer,
  );

  const SHIBAINUContract = await ethers.getContractAt(
    "IERC20",
    SHIBAINUAddress,
    signer,
  );

  const UNIRouterContract = await ethers.getContractAt(
    "IUniswapV2Router01",
    UNIRouterAddress,
    signer,
  );

  console.log("Lets go.....");
  const threshodBalance = await THRESHOLDContract.balanceOf(
    impersonatorAddress,
  );
  const shibaInuBalance = await SHIBAINUContract.balanceOf(impersonatorAddress);

  console.log("-----Before-----\n");

  console.log("Balance of threshold:", ethers.formatUnits(threshodBalance, 18));
  console.log("Balance of shibaInu", ethers.formatUnits(shibaInuBalance, 18));

  console.log("checking something...");

  const getFactoryContracAddress = await UNIRouterContract.factory();

  const FactoryContract = await ethers.getContractAt(
    "IUniswapV2Factory",
    getFactoryContracAddress,
    signer,
  );

  const createPoolAddress = await FactoryContract.createPair(
    THRESHOLDAddress,
    SHIBAINUAddress,
  );

  //   Get the pool address from the pairs and see if a valid address exist: after checking and the value os addres 0x00 which is zero, I resolve to cretaing a pair before getPair.

  const poolAddress = await FactoryContract.getPair(
    THRESHOLDAddress,
    SHIBAINUAddress,
  );

  console.log("Pool address:", poolAddress);

  //   if (poolAddress === ethers.ZeroAddress) {
  //     console.log("Pair does NOT exist.");
  //   }

  //   if (poolAddress === ethers.ZeroAddress) {
  //     console.log("Pair does NOT exist.");
  //     return;
  //   }

  const poolContract = await ethers.getContractAt(
    "IERC20",
    poolAddress,
    signer,
  );

  const decimalPoolAdress = await poolContract.decimals();
  const balanceOfPoolAddress = await poolContract.balanceOf(
    impersonatorAddress,
  );

  console.log(getFactoryContracAddress);
  console.log(poolAddress);
  //   console.log(FactotryContract);

  console.log("pool decimal:", decimalPoolAdress);

  console.log(
    "pool balance of address:",
    ethers.formatUnits(balanceOfPoolAddress, decimalPoolAdress),
  );

  //   since there is no liquidity, we need to add before removing, hence, we will allow our token to approve the spender which is the router in this instance

  const amountA = ethers.parseUnits("10", 18);
  const amountB = ethers.parseUnits("1000000", 18);

  await (await THRESHOLDContract.approve(UNIRouterAddress, amountA)).wait();

  await (await SHIBAINUContract.approve(UNIRouterAddress, amountB)).wait();

  //   get my amounts min: I don’t care how much I get back — just don’t revert. hence, I'm removing slippage protection completely.
  const amountAmin = 0n;
  const amountBmin = 0n;

  const deadline = (await helpers.time.latest()) + 300;

  //   Add Liquidity
  await (
    await UNIRouterContract.addLiquidity(
      THRESHOLDAddress,
      SHIBAINUAddress,
      amountA,
      amountB,
      amountAmin,
      amountBmin,
      impersonatorAddress,
      deadline,
    )
  ).wait();

  // After adding liquidity

  const ThresholdBalanceAfterAddingLiquidity =
    await THRESHOLDContract.balanceOf(impersonatorAddress);

  const ShibBalanceeAfterAddingLiquidity = await SHIBAINUContract.balanceOf(
    impersonatorAddress,
  );

  console.log("\n-----After-----\n");
  console.log(
    "Threshold:",
    ethers.formatUnits(ThresholdBalanceAfterAddingLiquidity, 18),
  );
  console.log(
    "SHIB:",
    ethers.formatUnits(ShibBalanceeAfterAddingLiquidity, 18),
  );

  const liquidity = await poolContract.balanceOf(impersonatorAddress);

  console.log("\n-----Checks-----\n");

  console.log(
    "\n LP Balance:",
    ethers.formatUnits(liquidity, decimalPoolAdress),
  );

  // Check allowance before and after approve
  const allowanceBefore = await poolContract.allowance(
    impersonatorAddress,
    UNIRouterAddress,
  );
  console.log(
    "Allowance before approve:",
    ethers.formatUnits(allowanceBefore, decimalPoolAdress),
  );

  await (await poolContract.approve(UNIRouterAddress, liquidity)).wait();

  const allowanceAfter = await poolContract.allowance(
    impersonatorAddress,
    UNIRouterAddress,
  );
  console.log(
    "Allowance after approve:",
    ethers.formatUnits(allowanceAfter, decimalPoolAdress),
  );

  // Check pool reserves
  const poolPairContract = await ethers.getContractAt(
    "IERC20",
    poolAddress,
    signer,
  );
  //   const reserves = await poolPairContract.getReserves();
  //   console.log("Reserve0:", reserves[0].toString());
  //   console.log("Reserve1:", reserves[1].toString());

  // Check total supply of LP token
  const totalSupply = await poolContract.totalSupply();
  console.log(
    "LP Total Supply:",
    ethers.formatUnits(totalSupply, decimalPoolAdress),
  );

  const newDeadline = (await helpers.time.latest()) + 300;

  //   const MINIMUM_LIQUIDITY = 1000n;

  //   const liquidityToRemove = liquidity;

  await (
    await UNIRouterContract.removeLiquidity(
      THRESHOLDAddress,
      SHIBAINUAddress,
      liquidity,
      amountAmin,
      amountBmin,
      impersonatorAddress,
      newDeadline,
    )
  ).wait();

  //   After removing liquidity
  const newThresholdBalance = await THRESHOLDContract.balanceOf(
    impersonatorAddress,
  );
  const newShibBalance = await SHIBAINUContract.balanceOf(impersonatorAddress);

  console.log("Threshold:", ethers.formatUnits(newThresholdBalance, 18));
  console.log("SHIB:", ethers.formatUnits(newShibBalance, 18));
};

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
