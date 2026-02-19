// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {SchoolToken} from "./SchoolToken.sol";

contract SchoolManagementSystem {

    SchoolToken public token;
    address public owner;

    constructor(address _token) {
        token = SchoolToken(_token);
        owner = msg.sender;

        schoolFeesPerLevel[100] = 2000;
        schoolFeesPerLevel[200] = 5000;
        schoolFeesPerLevel[300] = 8000;
        schoolFeesPerLevel[400] = 10000;
    }

  
    struct Student {
        string name;
        uint16 level;
        uint256 feesPaid;
        bool paymentStatus;
        uint256 timeStamp;
        address studentAddress;
    }

    struct Staff {
        string name;
        string role;
        uint256 salary;
        bool paymentStatus;
        uint256 timeStamp;
        address staffAddress;
    }

    mapping(address => Student) public students;
    address[] public studentAddresses;

    mapping(address => Staff) public staffs;
    address[] public staffAddresses;

    mapping(uint16 => uint256) private schoolFeesPerLevel;


    event StudentRegistered(
        address indexed student,
        string name,
        uint16 level,
        uint256 amountPaid,
        uint256 timestamp
    );

    event StaffRegistered(
        address indexed staff,
        string name,
        string role,
        uint256 salary
    );

    event StaffPaid(
        address indexed staff,
        uint256 amount,
        uint256 timestamp
    );


    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }


    function registerStudent(
        string memory _name,
        uint16 _level
    ) public {

        require(students[msg.sender].timeStamp == 0, "Already registered");

        uint256 fees = schoolFeesPerLevel[_level];
        require(fees > 0, "Invalid level");

        require(token.balanceOf(msg.sender) >= fees, "Insufficient funds");
        require(token.allowance(msg.sender, address(this)) >= fees, "Insufficient allowance");

        bool success = token.transferFrom(msg.sender, address(this), fees);
        require(success, "Fee payment failed");

        students[msg.sender] = Student({
            name: _name,
            level: _level,
            feesPaid: fees,
            paymentStatus: true,
            timeStamp: block.timestamp,
            studentAddress: msg.sender
        });

        studentAddresses.push(msg.sender);

        emit StudentRegistered(
            msg.sender,
            _name,
            _level,
            fees,
            block.timestamp
        );
    }

    function getAllStudents() public view returns (Student[] memory) {
        Student[] memory allStudents = new Student[](studentAddresses.length);

        for (uint i = 0; i < studentAddresses.length; i++) {
            allStudents[i] = students[studentAddresses[i]];
        }

        return allStudents;
    }


    function registerStaff(
        address _staffAddress,
        string memory _name,
        string memory _role,
        uint256 _salary
    ) public onlyOwner {

        require(_staffAddress != address(0), "Invalid address");
        require(staffs[_staffAddress].staffAddress == address(0), "Staff already registered");
        require(_salary > 0, "Invalid salary");

        staffs[_staffAddress] = Staff({
            name: _name,
            role: _role,
            salary: _salary,
            paymentStatus: false,
            timeStamp: 0,
            staffAddress: _staffAddress
        });

        staffAddresses.push(_staffAddress);

        emit StaffRegistered(
            _staffAddress,
            _name,
            _role,
            _salary
        );
    }

    function payStaff(address _staffAddress) public onlyOwner {

        require(staffs[_staffAddress].staffAddress != address(0), "Staff not found");

        Staff storage staffMember = staffs[_staffAddress];

        require(!staffMember.paymentStatus, "Already paid");
        require(token.balanceOf(address(this)) >= staffMember.salary, "Insufficient contract balance");

        bool success = token.transfer(_staffAddress, staffMember.salary);
        require(success, "Salary payment failed");

        staffMember.paymentStatus = true;
        staffMember.timeStamp = block.timestamp;

        emit StaffPaid(
            _staffAddress,
            staffMember.salary,
            block.timestamp
        );
    }

    function getAllStaff() public view returns (Staff[] memory) {
        Staff[] memory allStaff = new Staff[](staffAddresses.length);

        for (uint i = 0; i < staffAddresses.length; i++) {
            allStaff[i] = staffs[staffAddresses[i]];
        }

        return allStaff;
    }
}
