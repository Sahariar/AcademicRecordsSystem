// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 1. Import the Forge Standard Test library
import {Test, console} from "lib/forge-std/src/Test.sol";

// 2. Import your actual smart contract
import {AcademicRecordsSystem} from "src/Contracts/AcademicRecordsSystem.sol";

contract AcademicRecordsSystemTest is Test {
    AcademicRecordsSystem public system;

    // setup Inti Address
    address public head = address(0x10000);
    address public staff = address(0x2300);
    address public stranger = address(0x4340);

    // 3. The setUp function runs before every single test case
    function setUp() public {
        // Deploy your contract here so it's fresh for every test
        vm.prank(head);
        system = new AcademicRecordsSystem();
    }

    // 4. Test functions MUST start with the word "test"
    function test_registerStudentSuccessfully() public {
        vm.prank(head);
        system.registerStudent("Kabir", 20, "ka@gmail.com", "Arts");
        assertEq(system.totalStudent(), 1);

        vm.prank(head);
        AcademicRecordsSystem.Student memory student = system.getStudentById(20261001);

        // Example assertion: Assert that a value matches what you expect
        // assertEq(studentContract.someVariable(), expectedValue);

        assertEq(student.name, "Kabir");
        assertTrue(student.isActive);
    }

    function test_ExpectRevert_WhenUserTryToRegisterStudent() public {
        vm.prank(stranger);
        vm.expectRevert("Not academicHead so you can't add");
        system.registerStudent("stranger", 20, "bob@gmail.com", "Hacking");
    }

    function test_ExpectRevert_WhenUserUpdateStudent() public {
        vm.prank(head);
        system.registerStudent("Muyka", 20, "Mudob@gmail.com", "CSE");

        vm.prank(head);
        system.deactivateStudent(20261001);

        vm.prank(head);
        vm.expectRevert("Cannot update an inactive student");

        system.updateStudent(20261001, "Charlie", 24, "charlie@gmail.com", "CSE");
    }

    function test_deactivateAndActivateStudent() public {
        vm.prank(head);
        system.registerStudent("Harry", 19, "harry@hogwarts.edu", "Gryffindor");

        vm.prank(head);
        system.deactivateStudent(20261001);

        vm.prank(head);
        AcademicRecordsSystem.Student memory student = system.getStudentById(20261001);
        assertFalse(student.isActive);
        // 3. Activate
        vm.prank(head);
        system.activateStudent(20261001);

        vm.prank(head);
        student = system.getStudentById(20261001);
        assertTrue(student.isActive);
    }

    function test_Fail_deactivateExsitingStudent() public {
        vm.startPrank(head);
        vm.expectRevert("Student Not found Here");
        system.deactivateStudent(999999);
    }

    function test_Fail_activateExsitingStudent() public {
        vm.startPrank(head);
        vm.expectRevert("Student Not found Here");
        system.activateStudent(9999999);
    }

    function test_RegisterStaffSuccessfully() public {
        vm.prank(head);
        system.registerStaff(staff, "Professor McGonagall");

        // Verify staff was created and is active
        (string memory name,, bool isActive) = system.staffMembers(staff);
        assertEq(name, "Professor McGonagall");
        assertTrue(isActive);
    }

    function test_Fail_RegisterExistingStaff() public {
        vm.startPrank(head);
        system.registerStaff(staff, "Professor McGonagall");

        // This second attempt should trigger the "Staff Already exists" require error
        vm.expectRevert("Staff Already exists");
        system.registerStaff(staff, "Professor Snape");
        vm.stopPrank();
    }

    function test_Fail_ActivateNonExistentStaff() public {
        vm.prank(head);
        vm.expectRevert("Staff Doesn't Exits");
        system.activateStaff(address(0xDEAD));
    }

    function test_Fail_DeactivateNonExistentStaff() public {
        vm.prank(head);
        vm.expectRevert("Staff Doesn't Exits");
        system.deactivateStaff(address(0xDEAD));
    }

    function test_Fail_StrangerCannotDeactivateStaff() public {
        // First, head setups a valid staff member
        vm.prank(head);
        system.registerStaff(staff, "Professor Lupin");

        // Stranger tries to deactivate them
        vm.prank(stranger);
        vm.expectRevert("Not academicHead so you can't add");
        system.deactivateStaff(staff);
    }

    function test_Fail_DeactivatedStaffCannotUpdateStudent() public {
        // 1. Setup staff and student
        vm.startPrank(head);
        system.registerStaff(staff, "Professor Lockhart");
        system.registerStudent("Ron", 19, "ron@edu.com", "Herbology");
        // 2. Deactivate the staff member
        system.deactivateStaff(staff);
        vm.stopPrank();

        // 3. Deactivated staff tries to update student
        vm.prank(staff);
        vm.expectRevert("Not authorized: Must be Academic Head or Staff");
        system.updateStudent(20261001, "Ron Weasley", 19, "ron@edu.com", "Herbology");
    }
}
