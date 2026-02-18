// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {SafeVault} from "../src/SafeVault.sol";

contract DeploySafeVault is Script {
    SafeVault public safeVault;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        safeVault = new SafeVault();

        vm.stopBroadcast();
    }
}
