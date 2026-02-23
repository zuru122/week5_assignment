// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {PropertyManagementSystem} from "../src/PropertyManagementSystem.sol";
import {MyToken} from "../src/MyToken";

contract DeployPropertyManagementSyetem is Script {
    PropertyManagementSystem public propertyManagementSystem;


    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        counter = new Counter();

        vm.stopBroadcast();
    }
}
