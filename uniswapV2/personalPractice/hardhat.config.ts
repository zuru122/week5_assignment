import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

import * as dotenv from "dotenv";
dotenv.config();

const { MAINNET_RPC_URL } = process.env;

const config: HardhatUserConfig = {
  solidity: "0.8.28",

  networks: {
    hardhat: {
      forking: {
        url: `${MAINNET_RPC_URL}`,
      },
    },
  },
};

export default config;
