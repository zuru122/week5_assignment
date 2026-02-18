// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {SafeVault} from "../src/SafeVault.sol";
import {ERC20} from "../src/ERC20.sol";

contract DeploySafeVault is Script {
    SafeVault public safeVault;
    ERC20 public token;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        token = new ERC20("ZuruOnyx", "ZO", 1000000 ether);
        safeVault = new SafeVault(address(token));

        vm.stopBroadcast();
    }
}
