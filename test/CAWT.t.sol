// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../src/CAWT.sol";
import "../src/CAWTSale.sol";

contract CAWTTest is Test {
    CAWT public token;
    CAWTSale public sell;

    function setUp() public {
        vm.startPrank(0xC12171f27617734fDa78DD13d3E24762F6481684);
        sell = new CAWTSale();
        token = new CAWT(
            0xC12171f27617734fDa78DD13d3E24762F6481684,
            address(sell)
        );

        sell.setUp(address(token));
        sell.setPrice(40);
    }

    function testBalanceOf() public {
        assertEq(
            token.balanceOf(0xC12171f27617734fDa78DD13d3E24762F6481684),
            1000e18
        );
    }

    function testBurn() public {
        token.burn(100e18);
        assertEq(
            token.balanceOf(0xC12171f27617734fDa78DD13d3E24762F6481684),
            900e18
        );
    }

    function testBuy() public {
        vm.stopPrank();
        hoax(0xBbd3b61B47D93469C757121b8C5A0a1e40B6bFBA, 100e18);
        //------------------------------------------
        sell.buy{value: 1e18}();
        assertEq(
            token.balanceOf(0xBbd3b61B47D93469C757121b8C5A0a1e40B6bFBA),
            40e18
        );
        //------------------------------------------
        vm.expectRevert("Minimum 0.025 BNB");
        sell.buy{value: 10000000}();
      

        // assertEq(token.balanceOf(address(this)), 100000e18);
    }
}
