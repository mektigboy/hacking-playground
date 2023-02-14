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

    mapping(address account => uint256 balance) public balances;

    //////////////////////
    /// EXTERNAL LOGIC ///
    //////////////////////

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function transfer(address _to, uint256 _amount) external {
        if (balances[msg.sender] >= _amount) {
            balances[_to] += _amount;
            balances[msg.sender] -= _amount;
        }
    }

    function withdrawAll() external nonReentrant {
        uint256 accountBalance = balances[msg.sender];

        if (accountBalance == 0) revert CFRVault__InsufficientBalance();

        balances[msg.sender] = 0;

        (bool success, ) = msg.sender.call{value: accountBalance}("");
        
        if (!success) revert CFRVault__ETHTransferFailed();
    }

    ///////////////
    /// GETTERS ///
    ///////////////

    function balance() external view returns (uint256) {
        return address(this).balance;
    }
}
