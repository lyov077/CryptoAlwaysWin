// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "../src/CAWT.sol";
import "../src/CAWTSale.sol";
import "../src/CAWTFarming.sol";
import "../src/CAWTLottery.sol";
import "forge-std/Test.sol";

contract CAWTLotteryTest is Test {
    CAWT public token;
    CAWTSale public sale;
    CAWTFarming public farming;
    CAWTLottery public lottery;

    function setUp() public {
        vm.startPrank(0xC12171f27617734fDa78DD13d3E24762F6481684);
        sale = new CAWTSale();
        farming = new CAWTFarming();
        lottery = new CAWTLottery(0x2673f4068Bb8336C7beBeBa02f62793FDf826c4c);
        token = new CAWT(
            0xC12171f27617734fDa78DD13d3E24762F6481684,
            address(farming),
            address(sale)
        );
        sale.setUp(address(token));
        sale.setPrice(40);
        farming.setToken(address(token));
        lottery.setToken(address(token));
        vm.stopPrank();
    }

    function testCreateLottery() public {
        vm.prank(0xC12171f27617734fDa78DD13d3E24762F6481684);
        lottery.createLottery();
        bytes32 lotteryId = lottery.lotteryIds(0);
        (uint256 start, CAWTLottery.LotteryStatus status) = lottery
            .lotteryPools(lotteryId);

        assertEq(start, block.timestamp);
        if (status != CAWTLottery.LotteryStatus.ACTIVE) {
            revert("StakeStatus must be ACTIVE");
        }
        assertEq(lottery.ticketsLeft(lotteryId), 100);
    }

    function testParticipate() public {
        vm.prank(0xC12171f27617734fDa78DD13d3E24762F6481684);
        lottery.createLottery();
        bytes32 lotteryId = lottery.lotteryIds(0);
        vm.startPrank(0xBbd3b61B47D93469C757121b8C5A0a1e40B6bFBA);

        deal(
            address(token),
            0xBbd3b61B47D93469C757121b8C5A0a1e40B6bFBA,
            10 * 10**18
        );
        deal(
            address(token),
            0xE6E424fDD514221c12D67027e7E9AFA0e6E578bB,
            10 * 10**18
        );
        deal(
            address(token),
            0xC88Da45550e3978DC9c9B1E08851A6e9DfE85Dd4,
            100 * 10**18
        );
        deal(
            address(lottery),
            100 * 10**18
        );
        token.approve(address(lottery), 1 * 10**18);
        lottery.participate(lotteryId, 77);

        //@note TRY TO PARTICIPATE WITH THE SAME NUMBER
        vm.expectRevert("Lottery: This number is already taken.");
        lottery.participate(lotteryId, 77);
        //@note TRY TO PARTICIPATE WITH THE NUMBER OUT OF RANGE
        vm.expectRevert("Lottery: Invalid number.");
        lottery.participate(lotteryId, 100);

        assertEq(lottery.ticketsLeft(lotteryId), 99);
        (, CAWTLottery.LotteryStatus status) = lottery.lotteryPools(lotteryId);
        if (status != CAWTLottery.LotteryStatus.ACTIVE) {
            revert("StakeStatus must be ACTIVE");
        }
        vm.stopPrank();

        vm.prank(0xE6E424fDD514221c12D67027e7E9AFA0e6E578bB);
        token.approve(address(lottery), 1 * 10**18);

        vm.prank(0xE6E424fDD514221c12D67027e7E9AFA0e6E578bB);
        lottery.participate(lotteryId, 99);

        vm.startPrank(0xC88Da45550e3978DC9c9B1E08851A6e9DfE85Dd4);
        token.approve(address(lottery), 100 * 10**18);

        for (uint8 i = 0; i < 99; i++) {
            if (i == 77 || i == 99) {
                continue;
            }
            lottery.participate(lotteryId, i);
        }
        (, CAWTLottery.LotteryStatus status1) = lottery.lotteryPools(lotteryId);
        if (status1 != CAWTLottery.LotteryStatus.PENDING) {
            revert("StakeStatus must be PENDING");
        }
        assertEq(lottery.ticketsLeft(lotteryId), 0);
        vm.stopPrank();
        vm.prank(0x2673f4068Bb8336C7beBeBa02f62793FDf826c4c);
        lottery.sendPrize(lotteryId, 99);
        assertEq(address(0xE6E424fDD514221c12D67027e7E9AFA0e6E578bB).balance, 0.01 ether);
    }
}
