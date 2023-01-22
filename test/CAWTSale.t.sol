// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "../src/CAWT.sol";
import "../src/CAWTSale.sol";
import "../src/CAWTFarming.sol";
import "forge-std/Test.sol";

contract CAWTSaleTest is Test {
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

    function testBuy() public {
        hoax(0xBbd3b61B47D93469C757121b8C5A0a1e40B6bFBA, 100e18);
        //------------------------------------------
        sale.buy{value: 1e18}();
        assertEq(
            token.balanceOf(0xBbd3b61B47D93469C757121b8C5A0a1e40B6bFBA),
            40e18
        );
        //------------------------------------------
    }

    function testRevertBuy() public {
        vm.expectRevert("Minimum 0.025 BNB");
        sale.buy{value: 10000000}();
    }
}
