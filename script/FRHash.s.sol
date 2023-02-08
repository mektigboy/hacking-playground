// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {console} from "forge-std/console.sol";
import {Script} from "forge-std/Script.sol";

import {FRHash} from "src/front-running/FRHash.sol";

contract FRHashScript is Script {
    function run() public {
        vm.startBroadcast();

        FRHash hash = (new FRHash){value: 0.01 ether}();

        console.log("Contract `Hash` deployed to: ", address(hash));

        vm.stopBroadcast();
    }
}
