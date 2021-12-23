// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "base64-sol/base64.sol";
import "./Receivers.sol";
import "./Vis/VisCaller.sol";

uint256 constant theZeroDay = 5000000; // 13698 years
uint256 constant secondsInDay = 60 * 60 * 24;
uint256 constant dropPeriod = 100; //days
string constant COLLECTION_NAME = "SAVE THE DATE";
string constant TOKEN_NAME = "STD";

contract TheDate is
    ERC721URIStorage,
    Ownable,
    PaymentRecievers,
    SaveDateVisCaller
{
    uint256 public tokensBoughtInPast;
    address visualizerAddress;

    constructor() ERC721(COLLECTION_NAME, TOKEN_NAME) {
        // tokenCounter = 0;
    }

    modifier dateBounds(uint256 day) {
        require(day >= 0 && day <= theZeroDay * 2, "Out of date bounds");
        _;
    }

    // 100 = $40 = 0.01eth
    function getAvailability(uint256 day)
        public
        view
        dateBounds(day)
        returns (uint256)
    {
        if (ownerOf(day) == address(0)) {
            return 0;
        }
        uint256 currentDay = block.timestamp / secondsInDay;
        uint256 diff = day - currentDay;
        if (diff < dropPeriod) {
            return 100 * 100 * 100; //100 eths
        }
        return 100 + tokensBoughtInPast * 10;
    }

    function create(uint256 day) public payable dateBounds(day) {
        uint256 price = getAvailability(day);
        require(price > 0);
        require(msg.value >= price);
        finishMinting(msg.sender, day);
        tokensBoughtInPast = tokensBoughtInPast + 1;
    }

    function dropMint(uint256 day) public dateBounds(day) {
        uint256 price = getAvailability(day);
        require(msg.sender == owner());
        require(price > 0);
        finishMinting(address(this), day);
    }

    function finishMinting(address receiver, uint256 tokenId) {
        string imageURI = getDateImage(tokenId);
        string name = getDateName(tokenId);
        string desc = getDateDesc(tokenId);

        _safeMint(receiver, tokenId);
        _setTokenURI(tokenId, formatTokenURI(imageURI, name, desc));
    }

    function formatTokenURI(
        string memory imageURI,
        string memory _name,
        string memory _desc
    ) public pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                _name, // You can add whatever name here
                                '", "description":"',
                                _desc,
                                '", "attributes":"", "image":"',
                                imageURI,
                                '"}'
                            )
                        )
                    )
                )
            );
    }
}
