// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";
import {ERC20} from "../src/ERC20.sol";

contract DeployERC20 is Script {
    ERC20 public erc20;
    uint256 initialSupply = 10000 * 1e18;
    string tokenName = "ZuruOnyx";
    string tokenSymbol = "ZO";

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        erc20 = new ERC20(tokenName, tokenSymbol, initialSupply);

        vm.stopBroadcast();
    }
}
