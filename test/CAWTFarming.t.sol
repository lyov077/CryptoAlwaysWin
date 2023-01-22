// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "../src/CAWT.sol";
import "../src/CAWTSale.sol";
import "../src/CAWTFarming.sol";
import "../src/interfaces/ICAWTFarming.sol";
import "forge-std/Test.sol";

contract CAWTFarmingTest is Test {
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

    function testDeposit() public {
        //--------------------------------------------REVERTS-----------------------------------
        startHoax(0xBbd3b61B47D93469C757121b8C5A0a1e40B6bFBA, 100e18);

        vm.expectRevert("Farming: Should receive at least 0.01 ether.");
        farming.deposit{value: 0.00001 ether}(block.timestamp + 90000);

        vm.expectRevert("Farming: Should stake for at least 1 day.");
        farming.deposit{value: 0.1 ether}(block.timestamp + 80000);

        //--------------------------------------------FIRST FARMING------------------------------
        farming.deposit{value: 1 ether}(block.timestamp + 100000);
        bytes32 id = farming.farmIds(
            0xBbd3b61B47D93469C757121b8C5A0a1e40B6bFBA,
            0
        );

        (
            uint256 amount,
            uint256 start,
            uint256 end,
            CAWTFarming.StakeStatus stakeStatus
        ) = farming.farmPools(0xBbd3b61B47D93469C757121b8C5A0a1e40B6bFBA, id);
        assertEq(address(farming).balance, 1 ether);
        assertEq(amount, 1 ether);
        assertEq(start, block.timestamp);
        assertEq(end, block.timestamp + 100000);
        if (stakeStatus != CAWTFarming.StakeStatus.DEPOSITED) {
            revert("StakeStatus is not DEPOSITED");
        }

        vm.warp(block.timestamp + 60 * 60); // one hour later
        vm.stopPrank();
        //--------------------------------------------SECOND FARMING------------------------------

        startHoax(0x116422da50f39287d4a13a06c321B44111f66424, 100e18);
        farming.deposit{value: 0.1 ether}(block.timestamp + 90000);

        bytes32 id2 = farming.farmIds(
            0x116422da50f39287d4a13a06c321B44111f66424,
            0
        );
        (
            uint256 amount2,
            uint256 start2,
            uint256 end2,
            CAWTFarming.StakeStatus stakeStatus2
        ) = farming.farmPools(0x116422da50f39287d4a13a06c321B44111f66424, id2);

        assertEq(address(farming).balance, 1.1 ether);
        assertEq(amount2, 0.1 ether);
        assertEq(start2, block.timestamp);
        assertEq(end2, block.timestamp + 90000);
        if (stakeStatus2 != CAWTFarming.StakeStatus.DEPOSITED) {
            revert("StakeStatus is not DEPOSITED");
        }
    }

    function testPendingReward() external {
        startHoax(0xBbd3b61B47D93469C757121b8C5A0a1e40B6bFBA, 100e18);

        farming.deposit{value: 1 ether}(block.timestamp + 100000);

        bytes32 id = farming.farmIds(
            0xBbd3b61B47D93469C757121b8C5A0a1e40B6bFBA,
            0
        );

        vm.warp(block.timestamp + 1);
        assertEq(farming.pendingReward(id), farming.CAWTPerSec());

        vm.warp(block.timestamp + 99);
        assertEq(farming.pendingReward(id), 100 * farming.CAWTPerSec());

        vm.warp(block.timestamp + 99899);
        assertEq(farming.pendingReward(id), 99999 * farming.CAWTPerSec());

        vm.warp(block.timestamp + 1);
        assertEq(farming.pendingReward(id), 100000 * farming.CAWTPerSec());

        vm.warp(block.timestamp + 10000000);
        assertEq(farming.pendingReward(id), 100000 * farming.CAWTPerSec());

        vm.stopPrank();
        assertEq(farming.pendingReward(id), 0);
    }

    function xtestWithdraw() external {
        startHoax(0xBbd3b61B47D93469C757121b8C5A0a1e40B6bFBA, 100e18);

        farming.deposit{value: 1 ether}(block.timestamp + 100000);

        bytes32 id = farming.farmIds(
            0xBbd3b61B47D93469C757121b8C5A0a1e40B6bFBA,
            0
        );

        vm.warp(block.timestamp + 100000);
        farming.withdraw(id);

        (
            uint256 amount,
            uint256 start,
            uint256 end,
            CAWTFarming.StakeStatus stakeStatus
        ) = farming.farmPools(0xBbd3b61B47D93469C757121b8C5A0a1e40B6bFBA, id);

        assertEq(amount, 0);
        assertEq(start, 0);
        assertEq(end, 0);
        if (stakeStatus != CAWTFarming.StakeStatus.WITHDRAWN) {
            revert("StakeStatus is not WITHDRAWN");
        }
    }
}
