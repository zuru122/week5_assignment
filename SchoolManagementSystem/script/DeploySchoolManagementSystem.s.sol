// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {SchoolManagementSystem} from "../src/SchoolManagementSystem.sol";
import {SchoolToken} from "../src/SchoolToken.sol";

contract DeploySchoolManagementSystem is Script {
    SchoolManagementSystem public schoolManagementSystem;
    SchoolToken public schoolToken;


    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        schoolToken = new SchoolToken("School Token", "SCHL", 1000000 * 10**18);

        schoolManagementSystem = new SchoolManagementSystem(address(schoolToken));

        vm.stopBroadcast();
    }
}
