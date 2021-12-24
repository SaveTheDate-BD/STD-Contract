// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "./helpers/Receivers.sol";
import "./helpers/MetaDataHelper.sol";
import "hardhat/console.sol";

uint256 constant theZeroDay = 5000000; // 13698 years
uint256 constant secondsInDay = 60 * 60 * 24;
uint256 constant dropPeriod = 100; //days
string constant COLLECTION_NAME = "SAVE THE DATE";
string constant TOKEN_NAME = "STD";

contract SaveTheDate is
    IERC721Receiver,
    ERC721URIStorage,
    Ownable,
    PaymentRecievers,
    MetaDataHelper
{
    uint256 public tokensBought;

    constructor(address _visualizerAddress)
        ERC721(COLLECTION_NAME, TOKEN_NAME)
    {
        // tokenCounter = 0;
        addVisualizer(_visualizerAddress);
        setDefaultVisualizer(_visualizerAddress);
    }

    modifier dateBounds(uint256 day) {
        require(day >= 0 && day <= theZeroDay * 2, "Out of date bounds");
        _;
    }

    function getCurrentDay() internal view returns (uint256) {
        return (block.timestamp / secondsInDay) + theZeroDay;
    }

    // 100 = $40 = 0.01eth
    function getAvailability(uint256 day)
        public
        view
        dateBounds(day)
        returns (uint256)
    {
        if (_exists(day)) {
            return 0;
        }
        uint256 currentDay = getCurrentDay();
        // for the future
        console.log("dd", day, currentDay);
        if (day >= currentDay) {
            uint256 diff = day - currentDay;
            console.log("diff", diff);
            if (diff < dropPeriod) {
                return 100 * 100 * 100; //100 eths
            } else {
                return getUsualPrice();
            }
        } else {
            return getUsualPrice();
        }
    }

    function getUsualPrice() internal view returns (uint256) {
        return 100 + tokensBought * 10; // 0.01 eths +  0.001 x tokens
    }

    function create(uint256 day) public payable dateBounds(day) {
        uint256 price = getAvailability(day);
        require(price > 0);
        require(msg.value >= price);
        console.log(" =-=-= ", day);
        finishMinting(msg.sender, day);
        tokensBought = tokensBought + 1;
    }

    function dropMint(uint256 day) public dateBounds(day) {
        uint256 price = getAvailability(day);
        require(msg.sender == owner(), "This method available only for owner");
        require(price > 0, "not available token");
        finishMinting(address(this), day);
    }

    function finishMinting(address receiver, uint256 tokenId) private {
        string memory imageURI = getDateImage(tokenId);
        string memory name = getDateName(tokenId);
        string memory desc = getDateDesc(tokenId);
        // console.log("imageURI", imageURI);
        console.log("name", name);
        console.log("desc", desc);
        console.log("receiver", receiver);
        _safeMint(receiver, tokenId);
        _setTokenURI(tokenId, formatTokenURI(imageURI, name, desc));
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
