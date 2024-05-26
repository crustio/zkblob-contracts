// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {ZkBlob} from "../src/ZkBlob.sol";

contract ZkBlobScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        new ZkBlob(0x20574f8eb8B7Bd3f6E3C0Aa749681290BB8308e9);
        vm.stopBroadcast();
    }
}
