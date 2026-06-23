// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "lib/forge-std/src/Script.sol";

// 2. Import your actual smart contract
import {AcademicRecordsSystem} from "src/Contracts/AcademicRecordsSystem.sol";

contract AcademicRecordsSystemScript is Script {
    AcademicRecordsSystem public system;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        system = new AcademicRecordsSystem();

        vm.stopBroadcast();
    }
}
