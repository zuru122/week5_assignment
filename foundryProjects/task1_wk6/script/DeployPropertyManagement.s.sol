// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {PropertyManagementSystem} from "../src/PropertyManagementSystem.sol";
import {MyToken} from "../src/MyToken.sol";

contract DeployPropertyManagementSystem is Script {
    PropertyManagementSystem public propertyManagementSystem;
    MyToken public myToken;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        // Deploy MyToken and set the deployer as owner
        myToken = new MyToken(msg.sender);

        // Deploy PropertyManagementSystem with the token address
        propertyManagementSystem = new PropertyManagementSystem(address(myToken));

        vm.stopBroadcast();
    }
}