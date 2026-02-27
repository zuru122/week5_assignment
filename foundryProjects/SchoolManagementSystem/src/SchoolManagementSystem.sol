// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {SchoolToken} from "./SchoolToken.sol";

contract SchoolManagementSystem {

    SchoolToken public token;
    address public owner;

    constructor(address _token) {
        token = SchoolToken(_token);
        owner = msg.sender;

        schoolFeesPerLevel[100] = 2000 * (10**18);
        schoolFeesPerLevel[200] = 5000 * (10**18);
        schoolFeesPerLevel[300] = 8000 * (10**18);
        schoolFeesPerLevel[400] = 10000 * (10**18);
    }

    // using enum
    // I used Probation to identify new staff,
    // but after a month when they receive their first salary, 
    // their status changes to Active from probabtion.
    enum StaffStatus {
    Probation,
    Active,      
    Suspended
}
  
    struct Student {
        string name;
        uint16 level;
        uint256 feesPaid;
        bool paymentStatus;
        uint256 timeStamp;
        address studentAddress;
        bool exists;
        
    }

    struct Staff {
        string name;
        string role;
        uint256 salary;
        bool paymentStatusForTheMonth;
        uint256 totalPaymentReceived;
        uint256 hiredAt;
        uint256 lastPaymentDate;
        address staffAddress;
        StaffStatus status;
        bool exists;
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
            studentAddress: msg.sender,
            exists: true
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

    // Register staff
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
            paymentStatusForTheMonth: false,
            hiredAt: block.timestamp,            
            staffAddress: _staffAddress,
            lastPaymentDate: 0,
            status: StaffStatus.Probation,
            totalPaymentReceived: 0,
            exists: true
        });

        staffAddresses.push(_staffAddress);

        emit StaffRegistered(
            _staffAddress,
            _name,
            _role,
            _salary
        );
    }

    uint256 constant PAY_INTERVAL = 28 days;

    function payStaff(address _staffAddress) public onlyOwner {

        require(staffs[_staffAddress].staffAddress != address(0), "Staff not found");

        Staff storage staffMember = staffs[_staffAddress];
        require(staffMember.status == StaffStatus.Active || staffMember.status == StaffStatus.Probation, "Not eligible");
        require(block.timestamp >= staffMember.lastPaymentDate + PAY_INTERVAL, "Payment interval not reached");
        staffMember.lastPaymentDate = block.timestamp;
        require(token.balanceOf(address(this)) >= staffMember.salary, "Insufficient contract balance");

        bool success = token.transfer(_staffAddress, staffMember.salary);
        require(success, "Salary payment failed");

        staffMember.paymentStatusForTheMonth = true;
        staffMember.lastPaymentDate = block.timestamp;
        staffMember.totalPaymentReceived += staffMember.salary;

        if(staffMember.status == StaffStatus.Probation){
            staffMember.status = StaffStatus.Active;
        }

        emit StaffPaid(
            _staffAddress,
            staffMember.salary,
            block.timestamp
        );
    }

    // Suspend or activate a staff
    function toogleSuspension(address _staffAddress)public{
        require(staffs[_staffAddress].exists, "Staff does not exist");
        Staff storage staffMember = staffs[_staffAddress];
        staffMember.status = staffMember.status == StaffStatus.Suspended ? StaffStatus.Active : StaffStatus.Suspended;
    }

    function getAllStaff() public view returns (Staff[] memory) {
        Staff[] memory allStaff = new Staff[](staffAddresses.length);

        for (uint i = 0; i < staffAddresses.length; i++) {
            allStaff[i] = staffs[staffAddresses[i]];
        }

        return allStaff;
    }

    // Remove Student
    function removeStudent(address _studentAddress)public {
        require(students[_studentAddress].exists, "Student does not exist");
        for(uint i=0; i < studentAddresses.length; i++){
            if(studentAddresses[i] == _studentAddress){
                studentAddresses[i] = studentAddresses[studentAddresses.length - 1];
                studentAddresses.pop();
                delete students[_studentAddress];
            }
        }
    }

    // This function retuns the staff status string to be used when called.
    function getStaffStatus(StaffStatus _status) public pure returns(string memory){
        if(_status == StaffStatus.Probation){
            return "Staff on probation";
        }
        else if(_status == StaffStatus.Suspended){
            return "Staff suspended";
        }
        else if(_status == StaffStatus.Active){
            return "Staff active";
        }
        else{
            return "Unkown status";
        }
    }
    // this function return some data of the staff and along, shows the staff data
    function getStaffInfo(address _staffAddress) public view returns (string memory name, string memory role, uint256 salary, string memory statusString){
        Staff storage staffMember = staffs[_staffAddress];
        return(staffMember.name, staffMember.role, staffMember.salary, getStaffStatus(staffMember.status));
    }
}
