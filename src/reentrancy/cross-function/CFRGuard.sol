// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

/// @title CFRGuard
/// @author mektigboy
abstract contract CFRGuard {
    //////////////
    /// ERRORS ///
    //////////////

    error CFRGuard__NonReentrant();

    ///////////////
    /// STORAGE ///
    ///////////////

    bool internal locked;

    /////////////////
    /// MODIFIERS ///
    /////////////////

    modifier nonReentrant() {
        if (locked) revert CFRGuard__NonReentrant();

        locked = true;

        _;

        locked = false;
    }
}
