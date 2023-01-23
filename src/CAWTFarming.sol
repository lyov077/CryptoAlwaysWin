pragma solidity 0.8.17;
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CAWTFarming is Ownable {
    using Counters for Counters.Counter;
    IERC20 public token;
    Counters.Counter public _counter;
    uint256 public constant CAWTPerSec = 11574074074075;
    enum StakeStatus {
        NOTHING,
        DEPOSITED,
        CLAIMED,
        WITHDRAWN
    }
    struct Stake {
        uint256 amount;
        uint256 start;
        uint256 end;
        StakeStatus status;
    }
    event Deposit(address indexed user, uint256 amount, bytes32 stakeId);
    mapping(address => mapping(bytes32 => Stake)) public farmPools;
    mapping(address => bytes32[]) public farmIds;

    function setToken(address _token) external onlyOwner {
        token = IERC20(_token);
    }

    function deposit(uint256 _time) external payable {
        require(
            msg.value >= 0.01 ether,
            "Farming: Should receive at least 0.01 ether."
        );
        require(
            _time > block.timestamp + 86400,
            "Farming: Should stake for at least 1 day."
        );
        _counter.increment();
        bytes32 stakeId = keccak256(
            abi.encodePacked(
                msg.value,
                msg.sender,
                _time,
                block.timestamp,
                _counter.current()
            )
        );
        farmPools[msg.sender][stakeId] = Stake(
            msg.value,
            block.timestamp,
            _time,
            StakeStatus.DEPOSITED
        );
        farmIds[msg.sender].push(stakeId);
        emit Deposit(msg.sender, msg.value, stakeId);
    }

    function pendingReward(bytes32 _stakeId) public view returns (uint256) {
        Stake storage stakeInfo = farmPools[msg.sender][_stakeId];
        uint256 timePassed = block.timestamp - stakeInfo.start;
        if (stakeInfo.start == 0 || stakeInfo.end == 0) {
            return 0;
        }
        if (timePassed > stakeInfo.end - stakeInfo.start) {
            timePassed = stakeInfo.end - stakeInfo.start;
        }
        return (timePassed * CAWTPerSec * stakeInfo.amount) / 10**18;
    }

    function claim(bytes32 _stakeId) external {
        Stake storage stakeInfo = farmPools[msg.sender][_stakeId];
        require(
            stakeInfo.status == StakeStatus.DEPOSITED,
            "Farming: You need to deposit first."
        );
        require(
            farmPools[msg.sender][_stakeId].end <= block.timestamp,
            "Farming: It is too early to claim."
        );
        uint256 tokenAmount = pendingReward(_stakeId);
        stakeInfo.start = 0;
        stakeInfo.end = 0;
        stakeInfo.status = StakeStatus.CLAIMED;
        token.transfer(msg.sender, tokenAmount);
    }

    function withdraw(bytes32 _stakeId) external {
        Stake storage stakeInfo = farmPools[msg.sender][_stakeId];
        require(
            stakeInfo.status == StakeStatus.CLAIMED,
            "Farming: You need claim your ticket."
        );
        stakeInfo.status = StakeStatus.WITHDRAWN;
        uint256 amount = stakeInfo.amount;
        stakeInfo.amount = 0;

        payable(msg.sender).transfer(amount);
    }
}
