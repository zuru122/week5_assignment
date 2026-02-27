// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract MultiSignWallet {
    address[] public owners;
    mapping(address => bool) public isOwner;
    uint8 public requiredConfirmation;

    constructor(address addr1, address addr2, address addr3) {
        owners.push(addr1);
        owners.push(addr2);
        owners.push(addr3);

        requiredConfirmation = 2;

        isOwner[addr1] = true;
        isOwner[addr2] = true;
        isOwner[addr3] = true;
    }

    struct Transaction {
        uint256 transactionId;
        address to;
        uint256 value;
        bool executed;
        uint256 numberOfConfirmation;
    }

    uint256 public nextTransactionId;

    uint256[] public allTransactionsId;
    mapping(uint256 => Transaction) public transactionById;
    mapping(uint256 => mapping(address => bool)) public isConfirmed;

    // --- Modifiers ---
    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not owner");
        _;
    }

    modifier txExist(uint256 _transactionId) {
        require(transactionById[_transactionId].transactionId == _transactionId, "Transaction does not exist");
        _;
    }

    // --- Submit Transaction ---
    function submitTransaction(address _to, uint256 _value) public onlyOwner {
        require(_to != address(0), "Invalid address");

        nextTransactionId += 1;

        transactionById[nextTransactionId] = Transaction({
            transactionId: nextTransactionId,
            to: _to,
            value: _value,
            executed: false,
            numberOfConfirmation: 0
        });

        allTransactionsId.push(nextTransactionId);
    }

    // --- Confirm Transaction ---
    function confirmTransaction(uint256 _transactionId) public onlyOwner txExist(_transactionId) {
        Transaction storage transaction = transactionById[_transactionId];
        require(!transaction.executed, "Already executed");
        require(!isConfirmed[_transactionId][msg.sender], "Already confirmed");

        transaction.numberOfConfirmation = transaction.numberOfConfirmation + 1;
        isConfirmed[_transactionId][msg.sender] = true;
    }

    // --- Execute Transaction ---
    function executeTransaction(uint256 _transactionId) public onlyOwner txExist(_transactionId) {
        Transaction storage transaction = transactionById[_transactionId];
        require(!transaction.executed, "Already executed");
        require(transaction.numberOfConfirmation >= requiredConfirmation, "Not enough confirmations");

        transaction.executed = true;

        (bool success, ) = transaction.to.call{value: transaction.value}("");
        require(success, "Transaction failed");
    }

    // --- Receive Ether ---
    receive() external payable {}

}