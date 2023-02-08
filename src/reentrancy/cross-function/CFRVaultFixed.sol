// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "./CFRGuard.sol";

/// @title CFRVaultFixed
/// @author mektigboy
contract CFRVaultFixed is CFRGuard {
    //////////////
    /// ERRORS ///
    //////////////

    error CFRVault__InsufficientBalance();
    error CFRVault__ETHTransferFailed();

    ///////////////
    /// STORAGE ///
    ///////////////

    mapping(address user => uint256 balance) public userBalance;

    //////////////////////
    /// EXTERNAL LOGIC ///
    //////////////////////

    function deposit() external payable {
        userBalance[msg.sender] += msg.value;
    }

    function transfer(address _to, uint256 _amount) external {
        if (userBalance[msg.sender] >= _amount) {
            userBalance[_to] += _amount;
            userBalance[msg.sender] -= _amount;
        }
    }

    function withdrawAll() external nonReentrant {
        uint256 balanceUser = userBalance[msg.sender];

        if (balanceUser == 0) revert CFRVault__InsufficientBalance();

        userBalance[msg.sender] = 0;

        (bool success, ) = msg.sender.call{value: balanceUser}("");

        if (!success) revert CFRVault__ETHTransferFailed();
    }

    ///////////////
    /// GETTERS ///
    ///////////////

    function balance() external view returns (uint256) {
        return address(this).balance;
    }
}
