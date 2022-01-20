// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "./helpers/URIStorage.sol";
import "./openzeppelin/access/Ownable.sol";
import "./helpers/ArtManager.sol";
import "./helpers/FundManager.sol";
// import "./openzeppelin/token/ERC721/extensions/ERC721Royalty.sol";
import "hardhat/console.sol";

uint256 constant halfTokensAmount = 5000000; // 13698 years
uint256 constant secondsInDay = 60 * 60 * 24;

uint256 constant dropPeriod = 14; //days
uint256 constant pastPrice = 10**17; //0.1Eth
uint256 constant futurePrice = 12 * 10**18; //12Eth

string constant COLLECTION_NAME = "BIGDAY";
string constant TOKEN_NAME = "BGD";

struct PrivateMintPayload {
    uint256 day;
    address fundAddress;
    string art;
    address receiver;
}

// ERC721Royalty
contract SaveTheDate is
    Ownable,
    URIStorage,
    IERC721Receiver,
    ArtManager,
    FundManager
{
    event TokenMinted(
        uint256 day,
        address receiver,
        uint256 price,
        bool isPrivate
    );

    bool public isPublicSalesOpen;

    constructor() ERC721(COLLECTION_NAME, TOKEN_NAME) {
        isPublicSalesOpen = false;
    }

    modifier dateBounds(uint256 day) {
        require(day >= 0 && day <= halfTokensAmount * 2, "Out of date bounds");
        _;
    }

    modifier isOwner() {
        require(msg.sender == owner(), "This method available only for owner");
        _;
    }

    modifier isTokenOwner(uint256 tokenId) {
        // require(msg.sender == owner(), "This method available only for owner");
        // TOOD implement
        _;
    }

    function getCurrentDay() internal view returns (uint256) {
        return (block.timestamp / secondsInDay) + halfTokensAmount;
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
        if (day >= currentDay) {
            uint256 diff = day - currentDay;
            if (diff < dropPeriod) {
                return getFuturePrice();
            } else {
                return getPastPrice();
            }
        } else {
            return getPastPrice();
        }
    }

    function getPastPrice() internal view returns (uint256) {
        return pastPrice;
    }

    function getFuturePrice() internal view returns (uint256) {
        return futurePrice;
    }

    function mint(uint256 day) public payable dateBounds(day) {
        require(isPublicSalesOpen, "Public sales are closed now");
        uint256 price = getAvailability(day);
        require(price > 0, "The token already taken");
        require(msg.value >= price, "No enough funds");
        _safeMint(msg.sender, day);
        emit TokenMinted(day, msg.sender, price, false);
    }

    function burn(uint256 tokenId) public {
        _burn(tokenId);
    }

    function _privateMint(PrivateMintPayload memory dayPayload)
        public
        isOwner
        dateBounds(dayPayload.day)
    {
        uint256 day = dayPayload.day;
        uint256 price = getAvailability(day);
        require(price > 0, "not available token");
        address receiver = dayPayload.receiver;
        if (receiver == address(0)) {
            receiver = msg.sender;
        }
        // TODO ADD FUND
        // if (dayPayload.fundAddress != address(0)) {
        //     _addFund
        //
        // TODO ADD ARTIST
        _safeMint(receiver, day);
        emit TokenMinted(day, receiver, price, true);
    }

    function bulkPrivateMint(PrivateMintPayload[] memory daysPayload)
        public
        payable
        isOwner
        returns (bool res)
    {
        for (uint256 i = 0; i < daysPayload.length; i++) {
            _privateMint(daysPayload[i]);
        }
        res = true;
        return res;
    }

    function finishMinting(
        address receiver,
        uint256 tokenId,
        string memory metadataURI
    ) public payable isOwner {
        _safeMint(receiver, tokenId);
        _setTokenURI(tokenId, metadataURI);
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    // Transfer hook
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        console.log("BEFORE TRANSFER HOOK [%s]", msg.value);
    }

    // Royalties
    // function setTokenRoyalty(
    //     uint256 tokenId,
    //     address recipient,
    //     uint96 fraction
    // ) public isOwner{
    //     _setTokenRoyalty(tokenId, recipient, fraction);
    // }

    // function deleteDefaultRoyalty() public isOwner {
    //     _deleteDefaultRoyalty();
    // }
}
