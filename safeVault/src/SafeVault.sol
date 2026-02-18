// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "./ERC20.sol";

contract SafeVault {
    ERC20 public token;

    constructor(address _token) {
        token = ERC20(_token);
    }

    mapping(address => uint256) public ethBalances;
    mapping(address => uint256) public tokenBalances;


    event ETHDeposited(address indexed user, uint256 amount);
    event ETHWithdrawn(address indexed user, uint256 amount);
    event TokenDeposited(address indexed user, address indexed token, uint256 amount);
    event TokenWithdrawn(address indexed user, address indexed token, uint256 amount);  

    function depositETH()external payable {
        require(msg.value > 0, "Deposit must be greater than 0");
        ethBalances[msg.sender] += msg.value;
        emit ETHDeposited(msg.sender, msg.value);
    }

    function withdrawETH(uint256 amount) external {
        require(amount > 0, "Amount must be > 0");
        require(ethBalances[msg.sender] >= amount, "Insufficient balance");
        ethBalances[msg.sender] -= amount;
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "ETH transfer failed");
        emit ETHWithdrawn(msg.sender, amount);
    }

   function depositToken(uint256 amount) external {
        require(amount > 0, "Amount must be > 0");
        require(token.allowance(msg.sender, address(this)) >= amount, "Insufficient allowance");
        bool success = token.transferFrom(msg.sender, address(this), amount);
        require(success, "Token transfer failed");
        tokenBalances[msg.sender] += amount;
        emit TokenDeposited(msg.sender, address(token), amount);
    }

    function withdrawToken(uint256 amount) external {
        require(amount > 0, "Amount must be > 0");
        require(tokenBalances[msg.sender] >= amount, "Insufficient balance");
        tokenBalances[msg.sender]-= amount;
        bool success = token.transfer(msg.sender, amount);
        require(success, "Token transfer failed");
      
        emit TokenWithdrawn(msg.sender, address(token), amount);
    }

    function getEthBalance() external view returns (uint256) {
        return ethBalances[msg.sender];
    }

    function getTokenBalance() external view returns (uint256) {
        return tokenBalances[msg.sender];
    }   

}