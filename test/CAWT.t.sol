// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../src/CAWT.sol";

contract CAWTTest is Test {
    CAWT public token;   

    function setUp() public {
        vm.prank(0xC12171f27617734fDa78DD13d3E24762F6481684);
        token = new CAWT(0xC12171f27617734fDa78DD13d3E24762F6481684);
    }

    function testBalanceOf() public {
       token.balanceOf(0xC12171f27617734fDa78DD13d3E24762F6481684);
        assertEq(token.balanceOf(0xC12171f27617734fDa78DD13d3E24762F6481684), 1000e18);
    }

    function testBurn() public {
        vm.prank(0xC12171f27617734fDa78DD13d3E24762F6481684);
        token.burn(100e18);
        assertEq(token.balanceOf(0xC12171f27617734fDa78DD13d3E24762F6481684), 900e18);

    }
}