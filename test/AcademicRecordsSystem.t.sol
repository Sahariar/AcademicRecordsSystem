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
    address public hacker = address(0x4340);

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
        vm.prank(hacker);
        vm.expectRevert("Not academicHead so you can't add");
        system.registerStudent("Hacker", 20, "bob@gmail.com", "Hacking");
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
    // 5. Advanced: A Fuzz test (Foundry will automatically feed random inputs)
    // function testSetGrade(uint256 randomGrade) public {
    //     // vm.assume or bounds check if necessary
    //     // studentContract.setGrade(randomGrade);
    // }
}
