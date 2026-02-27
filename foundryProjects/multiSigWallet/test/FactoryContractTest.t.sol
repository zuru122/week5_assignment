// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {FactoryContract} from "../src/FactoryContract.sol";
import {MultiSigWallet} from "../src/MultiSigWallet.sol";

contract FactoryContractTest is Test {
    FactoryContract public factoryContract;

    address bob;
    address joy;
    address alice;

    function setUp() public {
        factoryContract = new FactoryContract();
        bob = makeAddr("bob");
        joy = makeAddr("joy");
        alice = makeAddr("alice");
    }

    function test_It_Deploys_a_Wallet() public {
        address[] memory owners = new address[](3);
        owners[0] = bob;
        owners[1] = joy;
        owners[2] = alice;

        vm.prank(bob);
        factoryContract.createChildMultiSigWallet(owners, 2);

        assertTrue(factoryContract.childrenContracts(0) != address(0));

        address createdWallet = factoryContract.userWallets(bob, 0);
        assertTrue(createdWallet != address(0));
    }

    function test_Children_Array_Grows() public {
        address[] memory owners = new address[](3);
        owners[0] = bob;
        owners[1] = joy;
        owners[2] = alice;

        vm.prank(bob);
        factoryContract.createChildMultiSigWallet(owners, 2);
        vm.prank(joy);
        factoryContract.createChildMultiSigWallet(owners, 2);
        vm.prank(alice);
        factoryContract.createChildMultiSigWallet(owners, 2);

        assert(factoryContract.getChildrenCount() == 3);
    }

    function test_Event_Emitted_On_Creation() public {
        address[] memory owners = new address[](3);
        owners[0] = bob;
        owners[1] = joy;
        owners[2] = alice;

        vm.expectEmit(false, false, false, false, address(factoryContract));
        emit FactoryContract.ChildContractCreated(address(0));

        vm.prank(bob);
        factoryContract.createChildMultiSigWallet(owners, 2);
    }

    // Verifies the deployed wallet has the correct owners set
    function test_Deployed_Wallet_Has_Correct_Owners() public {
        address[] memory owners = new address[](3);
        owners[0] = bob;
        owners[1] = joy;
        owners[2] = alice;

        vm.prank(bob);
        factoryContract.createChildMultiSigWallet(owners, 2);

        address walletAddr = factoryContract.userWallets(bob, 0);
        MultiSigWallet wallet = MultiSigWallet(payable(walletAddr));

        assertEq(wallet.owners(0), bob);
        assertEq(wallet.owners(1), joy);
        assertEq(wallet.owners(2), alice);
    }

    // Verifies the deployed wallet has the correct required approvals
    function test_Deployed_Wallet_Has_Correct_Required() public {
        address[] memory owners = new address[](3);
        owners[0] = bob;
        owners[1] = joy;
        owners[2] = alice;

        vm.prank(bob);
        factoryContract.createChildMultiSigWallet(owners, 2);

        address walletAddr = factoryContract.userWallets(bob, 0);
        MultiSigWallet wallet = MultiSigWallet(payable(walletAddr));

        assertEq(wallet.required(), 2);
    }

    // Bob and alice each create a wallet, assert they don't share entries
    function test_Different_Users_Have_Separate_Wallets() public {
        address[] memory owners = new address[](3);
        owners[0] = bob;
        owners[1] = joy;
        owners[2] = alice;

        vm.prank(bob);
        factoryContract.createChildMultiSigWallet(owners, 2);

        vm.prank(alice);
        factoryContract.createChildMultiSigWallet(owners, 2);

        address bobWallet = factoryContract.userWallets(bob, 0);
        address aliceWallet = factoryContract.userWallets(alice, 0);

        assertTrue(bobWallet != aliceWallet);
    }

    // Bob creates 2 wallets, assert both are stored under his address
    function test_Same_User_Multiple_Wallets() public {
        address[] memory owners = new address[](3);
        owners[0] = bob;
        owners[1] = joy;
        owners[2] = alice;

        vm.prank(bob);
        factoryContract.createChildMultiSigWallet(owners, 2);

        vm.prank(bob);
        factoryContract.createChildMultiSigWallet(owners, 2);

        address wallet1 = factoryContract.userWallets(bob, 0);
        address wallet2 = factoryContract.userWallets(bob, 1);

        assertTrue(wallet1 != address(0));
        assertTrue(wallet2 != address(0));
        assertTrue(wallet1 != wallet2);
    }

    // Factory should revert if required exceeds owners length
    function test_Cannot_Create_Wallet_Required_Exceeds_Owners() public {
        address[] memory owners = new address[](2);
        owners[0] = bob;
        owners[1] = joy;

        vm.prank(bob);
        vm.expectRevert("invalid required number of owners");
        factoryContract.createChildMultiSigWallet(owners, 3);
    }

    // Factory should revert if no owners are passed
    function test_Cannot_Create_Wallet_With_Zero_Owners() public {
        address[] memory owners = new address[](0);

        vm.prank(bob);
        vm.expectRevert("owners required");
        factoryContract.createChildMultiSigWallet(owners, 1);
    }

    // Factory should revert if a duplicate owner is passed
    function test_Cannot_Create_Wallet_With_Duplicate_Owner() public {
        address[] memory owners = new address[](3);
        owners[0] = bob;
        owners[1] = bob; // duplicate
        owners[2] = alice;

        vm.prank(bob);
        vm.expectRevert("owner is not unique");
        factoryContract.createChildMultiSigWallet(owners, 2);
    }

    // Factory should revert if a zero address is passed as an owner
    function test_Cannot_Create_Wallet_With_Zero_Address_Owner() public {
        address[] memory owners = new address[](3);
        owners[0] = bob;
        owners[1] = address(0); // invalid
        owners[2] = alice;

        vm.prank(bob);
        vm.expectRevert("invalid owner");
        factoryContract.createChildMultiSigWallet(owners, 2);
    }
}