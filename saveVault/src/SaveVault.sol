// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract saveVault {

    // mapping(address => uint256) public ethBalances;
    mapping(address => uint256) tokenBalances;
    mapping(address => uint256) public ethBalances;

    function deposithETh()external payable {
        require(msg.value > 0, "Deposit must be greater than 0");
        ethBalances[msg.sender] += msg.value;
    }

    function withdrawEth(uint256 amount) external {
        require(ethBalances[msg.sender] >= amount, "Insufficient balance");
        ethBalances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }

    function depositToken(uint256 amount) external {
        require(amount > 0, "Deposit must be greater than 0");
        tokenBalances[msg.sender] += amount;
    }

    function withdrawToken(uint256 amount) external {
        require(tokenBalances[msg.sender] >= amount, "Insufficient balance");
        tokenBalances[msg.sender] -= amount;
    }

    function getEthBalance() external view returns (uint256) {
        return ethBalances[msg.sender];
    }

    function getTokenBalance() external view returns (uint256) {
        return tokenBalances[msg.sender];
    }   

}