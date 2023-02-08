// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

/////////////////
/// ! WARNING ///
/////////////////

/// The purpose of this contract is to test front-running attacks.

/// @title Hash
/// @author mektigboy
contract FRHash {
    //////////////
    /// ERRORS ///
    //////////////

    error InvalidHash();

    error ETHTransferFailed();

    /// @dev `bytes4(keccak256(bytes("InvalidHash()")))`.
    uint256 constant ERROR__INVALID_HASH = 0x0af806e0;

    /// @dev `bytes4(keccak256(bytes("ETHTransferFailed()")))`.
    uint256 constant ERROR__ETH_TRANSFER_FAILED = 0xb12d13eb;

    //////////////
    /// EVENTS ///
    //////////////

    event HashSolved(address indexed solver);

    /// @dev `keccak256(bytes("HashSolved(address)"))`.
    uint256 constant EVENT__HASH_SOLVED =
        0x1ebe0a0f54454f9afdef98c1dde9d6fed83760af25095e2d013d8495509a83ba;

    ////////////
    /// DATA ///
    ////////////

    /// @dev `keccak256(bytes("password"))`.
    bytes32 constant HASH =
        0xb68fe43f0d1a0d7aef123722670be50268e15365401c442f8806ef83b612976b;

    ///////////////////
    /// CONSTRUCTOR ///
    ///////////////////

    constructor() payable {}

    //////////////////////
    /// EXTERNAL LOGIC ///
    //////////////////////

    function solve(string memory _hash) external {
        assembly {
            // In assembly `_hash` is just a pointer to the string.
            // It represents the address in memory where the data for our string starts.

            // At `_hash` we have the length of the string.
            // Here we get the size of the string.
            let stringSize := mload(_hash)

            // At `_hash` + 32 we have the string itself.
            // Here we add 32 to that address, so that we have the address of the string itself.
            let stringAddress := add(_hash, 32)

            // We then pass the address of the string, and its size. This will hash our string.
            let hash := keccak256(stringAddress, stringSize)

            // We compare `HASH` with `hash`, if they are not equal we will revert with custom error.
            // If they are equal we will send all the ETH stored in this contract.
            switch eq(HASH, hash)
            case 0 {
                mstore(0x00, ERROR__INVALID_HASH)
                revert(0x1c, 0x04)
            }
            default {
                let success := call(gas(), caller(), selfbalance(), 0, 0, 0, 0)

                if iszero(success) {
                    mstore(0x00, ERROR__ETH_TRANSFER_FAILED)
                    revert(0x1c, 0x04)
                }

                log2(0, 0, EVENT__HASH_SOLVED, caller())
            }
        }
    }

    ///////////////
    /// GETTERS ///
    ///////////////

    function hash() external pure returns (bytes32) {
        return HASH;
    }

    function balance() external view returns (uint256) {
        return address(this).balance;
    }
}
