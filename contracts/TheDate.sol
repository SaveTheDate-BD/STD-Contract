// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "./helpers/URIStorage.sol";
// import "hardhat/console.sol";

uint256 constant halfTokensAmount = 5000000; // 13698 years
uint256 constant secondsInDay = 60 * 60 * 24;
uint256 constant dropPeriod = 14; //days
string constant COLLECTION_NAME = "BIGDAY";
string constant TOKEN_NAME = "BGD";

// ERC721Royalty
contract SaveTheDate is URIStorage, IERC721Receiver {
    event MetadataRequested(uint256 day, address receiver, uint256 price);

    uint256 public tokensBought;
    bool public isPublicSalesOpen;
    mapping(uint256 => string[]) arts; // tokenId -> skinsId
    mapping(uint256 => string[]) names; // tokenId -> skinsId

    constructor() ERC721(COLLECTION_NAME, TOKEN_NAME) {
        tokensBought = 0;
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
                return 100 * 100 * 10; //10 eths
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

    function mint(uint256 day) public payable dateBounds(day) {
        uint256 price = getAvailability(day);
        require(price > 0);
        require(msg.value >= price);
        emit MetadataRequested(day, msg.sender, price);
        tokensBought = tokensBought + 1;
    }

    function burn(uint256 tokenId) public {
        _burn(tokenId);
    }

    function privateMint(uint256 day, address _receiver)
        public
        payable
        isOwner
        dateBounds(day)
    {
        uint256 price = getAvailability(day);
        require(price > 0, "not available token");
        address receiver = _receiver;
        if (receiver == address(0)) {
            receiver = msg.sender;
        }
        emit MetadataRequested(day, receiver, price);
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

    // TODO payable
    function addMetadata(uint256 tokenId, string changeId) public {
        require(_isExits(tokenId), "No such token exitst");
        require(
            _isOwner(tokenId, msg.sender),
            "Only token owner can change metadata"
        );
        arts[tokenId].push(changeId);
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
