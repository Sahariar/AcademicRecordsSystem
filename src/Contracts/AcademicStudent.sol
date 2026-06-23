// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract AcademicRecordsSystem {
    struct Student {
        string name;
        uint256 age;
        string email;
        string department;
        uint256 admissionDate;
        bool isActive;
    }

    struct Staff {
        string name;
        uint256 createdOn;
        bool isActive;
    }
    mapping(uint256 => Student) public students;
    mapping(address => Staff) public staffMembers;

    address public academicHead;

    uint256 private constant baseNumber = 20261001;
    uint256 private nextStudentId = baseNumber;

    constructor() {
        academicHead = msg.sender;
    }

    modifier onlyAuthorizePersonal() {
        require(
            msg.sender == academicHead || staffMembers[msg.sender].isActive,
            "Not authorized: Must be Academic Head or Staff"
        );
        _;
    }
    modifier onlyacademicHead() {
        require(
            msg.sender == academicHead,
            "Not academicHead so you can't add"
        );
        _;
    }

    modifier onlyStaff() {
        require(
            staffMembers[msg.sender].isActive,
            "Not Staff Members so you can Update"
        );
        _;
    }
    modifier studentExists(uint256 _id) {
        require(students[_id].admissionDate != 0, "Student Not found Here");
        _;
    }

    event CreateStudent(
        uint256 indexed id,
        string name,
        string email,
        uint256 admissionDate
    );
    event UpdateStudentEvent(
        uint256 indexed id,
        string name,
        string email,
        uint256 admissionDate
    );

    event CreateStaff(
        address indexed staffMembers,
        string name,
        uint256 createdOn
    );

    function registerStudent(
        string memory _name,
        uint256 _age,
        string memory _email,
        string memory _department
    ) public onlyacademicHead {
        uint256 currentId = nextStudentId;

        students[currentId] = Student({
            name: _name,
            age: _age,
            email: _email,
            department: _department,
            admissionDate: block.timestamp,
            isActive: true
        });

        nextStudentId++;
        emit CreateStudent(currentId, _name, _email, block.timestamp);
    }

    function updateStudent(
        uint256 _id,
        string memory _name,
        uint256 _age,
        string memory _email,
        string memory _department
    ) public onlyAuthorizePersonal studentExists(_id) {
        require(students[_id].isActive, "Cannot update an inactive student");

        Student storage studentToUpdate = students[_id];

        studentToUpdate.name = _name;
        studentToUpdate.age = _age;
        studentToUpdate.email = _email;
        studentToUpdate.department = _department;

        emit UpdateStudentEvent(
            _id,
            _name,
            _email,
            studentToUpdate.admissionDate
        );
    }

    function activateStudent(
        uint256 _id
    ) public onlyacademicHead studentExists(_id) {
        students[_id].isActive = true;
    }

    function deactivateStudent(
        uint256 _id
    ) public onlyacademicHead studentExists(_id) {
        students[_id].isActive = false;
    }

    function getStudentById(
        uint256 _id
    )
        public
        view
        onlyAuthorizePersonal
        studentExists(_id)
        returns (Student memory)
    {
        return students[_id];
    }

    function totalStudent() public view returns (uint256) {
        return nextStudentId - baseNumber;
    }

    function registerStaff(
        address _academicStaff,
        string memory _name
    ) public onlyacademicHead {
        require(
            staffMembers[_academicStaff].createdOn == 0,
            "Staff Already exists"
        );
        staffMembers[_academicStaff] = Staff({
            name: _name,
            createdOn: block.timestamp,
            isActive: true
        });

        emit CreateStaff(_academicStaff, _name, block.timestamp);
    }

    function activateStaff(address _academicStaff) public onlyacademicHead {
        require(
            staffMembers[_academicStaff].createdOn != 0,
            "Staff Doesn't Exits"
        );
        staffMembers[_academicStaff].isActive = true;
    }
    function deactivateStaff(address _academicStaff) public onlyacademicHead {
        require(
            staffMembers[_academicStaff].createdOn != 0,
            "Staff Doesn't Exits"
        );
        staffMembers[_academicStaff].isActive = false;
    }
}
