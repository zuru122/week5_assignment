// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "./interfaces/IERC20.sol";

contract Vault { 
    IERC20 public immutable token; // the token that the vault will hold
    uint256 public totalDeposits; // total amount of tokens deposited in the vault

    constructor(address _token) {
        token = IERC20(_token);
    }

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);


    mapping(address => uint256) public balances; // user address =>  amount deposited

    function deposit(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        token.transferFrom(msg.sender, address(this), _amount);
        balances[msg.sender] += _amount;
        totalDeposits += _amount;

        emit Deposited(msg.sender, _amount);
    }

    function withdraw(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        require(balances[msg.sender]  >= _amount, "insufficient funds");
        balances[msg.sender] -= _amount;
        totalDeposits -= _amount;
        token.transfer(msg.sender, _amount);
        emit Withdrawn(msg.sender, _amount);
    }

    function getBalance() external view returns (uint256) {
        return balances[msg.sender];
    }

    function getTotalDeposits() external view returns (uint256) {
        return totalDeposits;
    }   


    // NFT details

    function vaultInfo() external view returns (
    string memory tokenName,
    string memory tokenSymbol,
    uint8 decimals,
    uint256 _totalDeposits,
    address vaultAddress
    ) {
        return (
            token.name(),
            token.symbol(),
            token.decimals(),
            totalDeposits,
            address(this)
        );
    }


    // Build a factory that deploys vaults(using CREATE2) for any erc20 token... i.e a user can deposit a token and a vault is created for that token... users can add the vault

    // liquidity to the vault by depositing that same token to Deployment of the vault mints an NFT whose art is fully onchain sg showng the details about that vault like the token details, amount deposited etc...

    // You must use a mainnet fork for this task...which means you will be using reallife tokens as samples

    // You are free to use foundry or hardhat



}
