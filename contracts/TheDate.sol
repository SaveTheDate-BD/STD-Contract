// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "./MetaDataStorage.sol";
import "./TokenAsDate.sol";
import "./PublicSales.sol";
import "./openzeppelin/access/Ownable.sol";
import "./ArtManager.sol";
import "./OpenseaExtension.sol";
import "./openzeppelin/token/ERC721/extensions/ERC721Royalty.sol";
import "./openzeppelin/token/ERC721/IERC721Receiver.sol";
import "./openzeppelin/token/ERC721/ERC721.sol";

import "hardhat/console.sol";

string constant COLLECTION_NAME = "XXX XXX";
string constant TOKEN_NAME = "XXX";
address constant PROXY_REGISTERY_ADDRESS = address(0);
uint256 constant SET_ART_PRICE = 2 * 10**16; //0.02
struct PrivateMintPayload {
    uint256 day;
    address fundAddress;
    string art;
    address receiver;
}

// ERC721Royalty
contract SaveTheDate is
    Ownable,
    MetaDataStorage,
    IERC721Receiver,
    TokenAsDate,
    PublicSales,
    ArtManager,
    OpenseaExtension,
    ERC721
{
    event TokenMinted(
        uint256 day,
        address receiver,
        uint256 price,
        bool isPrivate
    );

    bool public isPublicSalesOpen;

    constructor()
        ERC721(COLLECTION_NAME, TOKEN_NAME)
        OpenseaExtension(PROXY_REGISTERY_ADDRESS)
    {
        isPublicSalesOpen = false;
    }

    modifier isTokenOwner(uint256 tokenId) {
        require(ownerOf(tokenId) == owner(), "Allowed for token owner onlt");
        _;
    }

    function getAvailability(uint256 day)
        public
        view
        dateBounds(day)
        returns (uint256)
    {
        if (_exists(day)) {
            return 0;
        }
        // for the future
        if (day >= _getCurrentDay() - _getFutureDay()) {
            return _getFuturePrice();
        } else {
            return _getPastPrice();
        }
    }

    function mint(uint256 day) public payable dateBounds(day) {
        require(isPrivateSalesOpened(), "Public sales are closed now");

        uint256 price = getAvailability(day);
        require(price > 0, "The token already taken");
        require(msg.value >= price, "No enough funds");

        _safeMint(msg.sender, day);
        emit TokenMinted(day, msg.sender, price, false);
    }

    function burn(uint256 _tokenId) public virtual isTokenOwner(_tokenId) {
        require(_exists(_tokenId), "URI set of nonexistent token");
        _clearTokenURI(_tokenId);
        _burn(_tokenId);
    }

    function privateMint(PrivateMintPayload memory dayPayload)
        public
        onlyOwner
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
        onlyOwner
        returns (bool res)
    {
        for (uint256 i = 0; i < daysPayload.length; i++) {
            privateMint(daysPayload[i]);
        }
        res = true;
        return res;
    }

    function setTokenURI(
        uint256 _tokenId,
        string memory _tokenURI,
        address artAddress
    ) public virtual onlyOwner {
        require(_exists(_tokenId), "URI set of nonexistent token");

        super._setTokenURI(_tokenId, _tokenURI);
    }

    function removeArt(
        uint256 tokenId,
        address collection,
        string memory artId
    ) public onlyOwner {
        _removeArt(tokenId, collection, artId);
    }

    function getCurrentArt(uint256 tokenId) public {
        _getCurrentArt(tokenId);
    }

    // function finishMinting(
    //     address receiver,
    //     uint256 tokenId,
    //     string memory metadataURI
    // ) public payable onlyOwner {
    //     _safeMint(receiver, tokenId);
    //     _setTokenURI(tokenId, metadataURI);
    // }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    // OpenSea
    function setProxyRegistry(address proxyAddress) public onlyOwner {
        _setProxyRegistry(proxyAddress);
    }

    // --
    // Overrides
    // --
    function setPrivateSales(bool newValue) public virtual override onlyOwner {
        super.setPrivateSales(newValue);
    }

    function setBasePriceStepMultiplier(uint256 newValue)
        public
        virtual
        override
        onlyOwner
    {
        super.setBasePriceStepMultiplier(newValue);
    }

    function setFuturePriceMultiplier(uint256 newValue)
        public
        virtual
        override
        onlyOwner
    {
        super.setFuturePriceMultiplier(newValue);
    }

    function setFutureDay(uint256 newValue) public virtual override onlyOwner {
        super.setFutureDay(newValue);
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(_tokenId),
            "ERC721URIStorage: URI query for nonexistent token"
        );
        string memory _uri = _getTokenURI(_tokenId);
        if (bytes(_uri).length > 0) {
            return _uri;
        }
        super.tokenURI(_tokenId);
    }

    //
    // Request art change by user
    function setArt(uint256 tokenId, string memory changeId) public payable {
        require(msg.value >= SET_ART_PRICE, "not funds enough");
        _setArt(tokenId, changeId, msg.sender);
    }

    function updateArt(
        uint256 tokenId,
        string memory artId,
        address publisher,
        address owner,
        address collection,
        uint256 artTokenId,
        string memory artUrl
    ) public onlyOwner {
        _updateArt(
            tokenId,
            artId,
            publisher,
            owner,
            collection,
            artTokenId,
            artUrl
        );
    }

    function withdrawRoyalties() public {
        _withdrawRoyalties();
    }

    /**
     * Override isApprovedForAll to whitelist user's OpenSea proxy accounts to enable gas-less listings.
     */
    function isApprovedForAll(address owner, address operator)
        public
        view
        virtual
        override
        returns (bool)
    {
        _isApprovedForAll(owner, operator);
        return super.isApprovedForAll(owner, operator);
    }

    /**
     * This is used instead of msg.sender as transactions won't be sent by the original token owner, but by OpenSea.
     */
    function _msgSender() internal view override returns (address sender) {
        return __msgSender();
    }

    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        public
        view
        returns (address receiver, uint256 royaltyAmount)
    {
        return _royaltyInfo(tokenId, salePrice);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721)
        returns (bool)
    {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            interfaceId == type(IERC2981).interfaceId ||
            super.supportsInterface(interfaceId);
        // if (interfaceId == LibRoyaltiesV2._INTERFACE_ID_ROYALTIES) {
        //     return true;
        // }
        // return super.supportsInterface(interfaceId);
    }
}
