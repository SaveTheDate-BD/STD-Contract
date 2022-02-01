pragma solidity 0.8.7;
import "../openzeppelin/token/ERC721/ERC721.sol";

contract UnknownERC721 is ERC721 {
    constructor() ERC721("UnknownNFT", "UNFT") {}
}
