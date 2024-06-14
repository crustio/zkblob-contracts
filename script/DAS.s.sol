// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {DAS} from "../src/DAS.sol";

contract DASScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        new DAS();
        vm.stopBroadcast();
    }
}
