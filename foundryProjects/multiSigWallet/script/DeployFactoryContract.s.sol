// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {FactoryContract} from "../src/FactoryContract.sol";


contract DeployFactoryContract is Script {
    FactoryContract public factoryContract;
    
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        factoryContract = new FactoryContract();

        vm.stopBroadcast();
    }
}
