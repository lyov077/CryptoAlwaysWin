pragma solidity ^0.8.17;
import "./CAWT.sol";
import "forge-std/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CAWTSale is Ownable {
    CAWT public token;
    uint256 public pricePerToken; //1 bnb = 40 tickets

    constructor() {}

    function setPrice(uint256 _price) public onlyOwner {
        pricePerToken = _price; //0.025 bnb = 1 ticket  => 40 
    }

    function setUp(address _token) external {
        token = CAWT(_token);
    }

    function buy() public payable {
        require(msg.value >= 25000000000000000, "Minimum 0.025 BNB");
        require(
            token.balanceOf(address(this)) >= msg.value * pricePerToken,
            "Not enough tokens in the reserve"
        );
        token.transfer(msg.sender, msg.value * pricePerToken);
    }
}
