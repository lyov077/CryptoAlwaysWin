pragma solidity ^0.8.17;
// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract CAWT is ERC20("Crypto Always Win Ticket", "CAWT") ,ERC20Burnable{
    constructor(address _treasury) {
        _mint(_treasury, 1000 * 10 ** decimals());
    }
}
