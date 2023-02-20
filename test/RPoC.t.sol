// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {console} from "forge-std/console.sol";

import {Test} from "forge-std/Test.sol";

import {REtherStore} from "src/reentrancy/REtherStore.sol";
import {IREtherStore, RAttack} from "src/reentrancy/RAttack.sol";

contract RPoC is Test {
    address OWNER = makeAddr("Owner");

    address ALICE = makeAddr("Alice");
    address BOB = makeAddr("Bob");
    address CAROL = makeAddr("Carol");

    address ATTACKER = makeAddr("Attacker");

    REtherStore rEtherStore;
    RAttack rAttack;

    function setUp() public {
        vm.deal(ALICE, 100 ether);
        vm.deal(BOB, 100 ether);
        vm.deal(CAROL, 100 ether);
        vm.deal(ATTACKER, 1 ether);

        vm.prank(OWNER);
        rEtherStore = new REtherStore();

        vm.prank(ATTACKER);
        rAttack = new RAttack(address(rEtherStore));
    }

    function test_PoC() public {
        console.log(
            "RETHERSTORE BALANCE (BEFORE DEPOSITS): ",
            rEtherStore.balance()
        );

        vm.prank(ALICE);
        rEtherStore.deposit{value: 10 ether}();
        console.log(
            "RETHERSTORE BALANCE + ALICE'S DEPOSIT: ",
            rEtherStore.balance()
        );

        vm.prank(BOB);
        rEtherStore.deposit{value: 10 ether}();
        console.log(
            "RETHERSTORE BALANCE + BOB'S DEPOSIT: ",
            rEtherStore.balance()
        );

        vm.prank(CAROL);
        rEtherStore.deposit{value: 10 ether}();
        console.log(
            "RETHERSTORE BALANCE + CAROL'S DEPOSIT: ",
            rEtherStore.balance()
        );

        console.log(
            "RETHERSTORE BALANCE (AFTER DEPOSITS / BEFORE ATTACK): ",
            rEtherStore.balance()
        );

        console.log("RATTACK'S BALANCE (BEFORE ATTACK): ", rAttack.balance());

        vm.prank(ATTACKER);
        rAttack.initializeAttack{value: 1 ether}();

        console.log("RATTACK'S BALANCE IN RETHERSTORE (BEFORE ATTACK): ", rEtherStore.balances(address(rAttack)));


        console.log("RATTACK'S BALANCE (AFTER ATTACK): ", rAttack.balance());
    }
}
