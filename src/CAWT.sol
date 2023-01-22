pragma solidity ^0.8.17;
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract CAWT is ERC20("Crypto Always Win Ticket", "CAWT"), ERC20Burnable {
    constructor(address _treasury, address _sale, address _farming) {
        _mint(_treasury, 1000 * 10**decimals());
        _mint(_sale, 100000 * 10**decimals());
        _mint(_farming, 100000 * 10**decimals());

    }
}
