// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../src/CAWT.sol";
import "../src/CAWTSale.sol";
import "../src/CAWTFarming.sol";

contract CAWTTest is Test {
    CAWT public token;
    CAWTSale public sale;
    CAWTFarming public farming;

    function setUp() public {
        vm.startPrank(0xC12171f27617734fDa78DD13d3E24762F6481684);
        sale = new CAWTSale();
        farming = new CAWTFarming();
        token = new CAWT(
            0xC12171f27617734fDa78DD13d3E24762F6481684,
            address(farming),
            address(sale)
        );
        sale.setUp(address(token));
        sale.setPrice(40);
        farming.setToken(address(token));
        vm.stopPrank();
    }

    function testBalanceOf() public {
        assertEq(
            token.balanceOf(0xC12171f27617734fDa78DD13d3E24762F6481684),
            1000e18
        );
        assertEq(token.balanceOf(address(farming)), 100000e18);
        assertEq(token.balanceOf(address(sale)), 100000e18);
    }

    function testBurn() public {
        hoax(0xC12171f27617734fDa78DD13d3E24762F6481684, 0);
        token.burn(100e18);
        assertEq(
            token.balanceOf(0xC12171f27617734fDa78DD13d3E24762F6481684),
            900e18
        );
    }
}
