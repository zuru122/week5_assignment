// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {SaveEther} from "../src/SaveEther.sol";

contract DeploySaveEther is Script {
    SaveEther public saveEther;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        saveEther = new SaveEther();

        vm.stopBroadcast();
    }
}
