// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {MultiSigWallet} from "./MultiSigWallet.sol";

contract FactoryContract {
    address[] public childrenContracts;
    event ChildContractCreated(address indexed childContract);

    mapping(address => address[]) public userWallets;

    function createChildMultiSigWallet(address[] memory _owners, uint _required) external {
         MultiSigWallet multiSigWallet = new MultiSigWallet(_owners, _required);
         childrenContracts.push(address(multiSigWallet));

         userWallets[msg.sender].push(address(multiSigWallet));

         emit ChildContractCreated(address(multiSigWallet));
    }

    function getChildrenCount() external view returns (uint) {
        return childrenContracts.length;
    }


}