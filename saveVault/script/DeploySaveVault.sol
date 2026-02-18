// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {saveVault} from "../src/SaveVault.sol";

contract SaveVaultScript is Script {
    saveVault public saveVault;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        saveVault = new saveVault();

        vm.stopBroadcast();
    }
}
