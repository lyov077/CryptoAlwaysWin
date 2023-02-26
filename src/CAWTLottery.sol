pragma solidity 0.8.17;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract CAWTLottery is Ownable {
    IERC20 public token;
    using SafeERC20 for IERC20;
    using Counters for Counters.Counter;
    Counters.Counter public _counter;

    address public randomGenerator;
    struct Lottery {
        uint256 start;
        address[100] _users;
        LotteryStatus status;
    }
    bytes32[] public lotteryIds;
    enum LotteryStatus {
        NOTHING,
        ACTIVE,
        PENDING,
        AWARDED
    }
    uint256 public constant TICKETS_COUNT = 100;
    uint256 public constant PRIZE = 0.01 ether;

    mapping(bytes32 => Lottery) public lotteryPools;

    constructor(address _randomGenerator) {
        randomGenerator = _randomGenerator;
    }

    function createLottery() public onlyOwner {
        bytes32 lotteryId = keccak256(
            abi.encodePacked(msg.sender, block.timestamp, _counter.current())
        );
        lotteryIds.push(lotteryId);
        _counter.increment();
        Lottery storage lottery = lotteryPools[lotteryId];
        lottery.start = block.timestamp;
        lottery.status = LotteryStatus.ACTIVE;
    }

    function participate(bytes32 lotteryId, uint8 lotteryNumber) public {
        require(lotteryNumber < TICKETS_COUNT, "Lottery: Invalid number.");
        require(
            lotteryPools[lotteryId].status == LotteryStatus.ACTIVE,
            "Lottery: Lottery is not active."
        );
        require(
            lotteryPools[lotteryId]._users[lotteryNumber] == address(0),
            "Lottery: This number is already taken."
        );
        token.safeTransferFrom(msg.sender, address(this), 10**18);
        lotteryPools[lotteryId]._users[lotteryNumber] = msg.sender;
        if (ticketsLeft(lotteryId) == 0) {
            lotteryPools[lotteryId].status = LotteryStatus.PENDING;
        }
        //participate in lottery
    }

    function ticketsLeft(bytes32 lotteryId) public view returns (uint256) {
        uint256 count = 0;
        for (uint256 i = 0; i < TICKETS_COUNT; i++) {
            if (lotteryPools[lotteryId]._users[i] == address(0)) {
                count++;
            }
        }
        return count;
    }

    function sendPrize(bytes32 lotteryId, uint256 random) public {
        require(
            msg.sender == randomGenerator,
            "Lottery: Only random generator can send prize."
        );

        require(
            lotteryPools[lotteryId].status == LotteryStatus.PENDING,
            "Lottery: Lottery is not pending."
        );
        require(address(this).balance >= PRIZE, "Lottery: Not enough funds.");
        lotteryPools[lotteryId].status = LotteryStatus.AWARDED;
        uint256 winnerIndex = random % TICKETS_COUNT;
        address winner = lotteryPools[lotteryId]._users[winnerIndex];
        delete lotteryPools[lotteryId]._users; // @todo: delete lottery
        payable(winner).transfer(PRIZE);
        //send prize to winner
    }

    function setToken(address _token) external onlyOwner {
        token = IERC20(_token);
    }
}
