// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "./Vault.sol";

contract VaultFactory {
    event VaultCreated(address indexed token, address indexed vault, address indexed deployer);

    mapping(address => address) public vaults; // token → vault
    
    address[] public allVaults;

    function createVault(address _token) external returns (address) {
        require(_token != address(0), "Zero address");
        require(vaults[_token] == address(0), "Vault already exists");

        bytes32 salt = keccak256(abi.encodePacked(_token));
        Vault vault  = new Vault{salt: salt}(_token);

        vaults[_token] = address(vault);
        allVaults.push(address(vault));

        emit VaultCreated(_token, address(vault), msg.sender);
        return address(vault);
    }

    function predictVaultAddress(address _token) external view returns (address) {
        bytes32 salt = keccak256(abi.encodePacked(_token));
        bytes memory bytecode = abi.encodePacked(
            type(Vault).creationCode,
            abi.encode(_token)
        );
        return address(uint160(uint256(keccak256(abi.encodePacked(
            bytes1(0xff),
            address(this),
            salt,
            keccak256(bytecode)
        )))));
    }

    function totalVaults() external view returns (uint256) {
        return allVaults.length;
    }
}