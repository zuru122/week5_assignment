// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {SafeVault} from "../src/SafeVault.sol";

contract DeploySaveVault is Script {
    safeVault public SafeVault;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        safeVault = new SafeVault();

        vm.stopBroadcast();
    }
}
