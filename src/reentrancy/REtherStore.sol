// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

/// @title REtherStore
/// @author mektigboy
contract REtherStore {
    //////////////
    /// ERRORS ///
    //////////////

    error REtherStore__InsufficientBalance();
    error REtherStore__CallFailed();

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

    function withdraw() external {
        uint256 accountBalance = balances[msg.sender];

        if (accountBalance == 0)
            revert REtherStore__InsufficientBalance();

        (bool success, ) = msg.sender.call{value: accountBalance}("");

        if (!success) revert REtherStore__CallFailed();

        balances[msg.sender] = 0;
    }

    ///////////////
    /// GETTERS ///
    ///////////////

    function balance() external view returns (uint256) {
        return address(this).balance;
    }
}
