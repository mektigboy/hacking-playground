// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {console} from "forge-std/console.sol";

import {Test} from "forge-std/Test.sol";

import {ROAttack} from "src/reentrancy/read-only/ROAttack.sol";
import {ROTarget} from "src/reentrancy/read-only/ROAttack.sol";

contract ROPoC is Test {
    address OWNER = makeAddr("Owner");
    address ATTACKER = makeAddr("Attacker");

    ROAttack roAttack;
    ROTarget roTarget;

    function setUp() public {
        vm.selectFork(vm.createFork(vm.envString("MAINNET_RPC_URL")));

        vm.deal(ATTACKER, 100010 ether);

        vm.prank(OWNER);
        roTarget = new ROTarget();

        vm.prank(ATTACKER);
        roAttack = new ROAttack(address(roTarget));
    }

    function test() public {
        vm.startPrank(ATTACKER);

        roAttack.setUp{value: 10 ether}();
        roAttack.attack{value: 100000 ether}();

        vm.stopPrank();
    }
}
