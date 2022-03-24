// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "./MetaDataStorage.sol";
import "./TokenAsDate.sol";
import "./openzeppelin/access/Ownable.sol";
import "./openzeppelin/token/ERC721/ERC721.sol";

import "hardhat/console.sol";

string constant COLLECTION_NAME = "XXX XXX";
string constant TOKEN_NAME = "XXX";
address constant PROXY_REGISTERY_ADDRESS = address(0);
uint256 constant SET_ART_PRICE = 1 * 10**16; //0.02
uint256 constant SET_ART_PRICE_OWNER = 5 * 10**17; //0.5

struct PrivateMintPayload {
    uint256 day;
    address fundAddress;
    string art;
    address receiver;
}

// ERC721Royalty
contract TheDate is Ownable, IERC721Receiver, TokenAsDate, ERC721 {
    event TokenMinted(
        uint256 day,
        address receiver,
        uint256 price,
        bool isPrivate
    );
    event MetadataSet(uint256 tokenId, string URI);
    event ArtUpdateRequested(
        uint256 tokenId,
        address collection,
        uint256 artId
    );
    event RoyaltiesRequested(address requester);
    bool public isPublicSalesOpen = true;
    string _contractMetadataURI;
    MetaDataStorage MetaDataStorageAddress;

    constructor(address _mdStorage, string memory _metadataURI)
        ERC721(COLLECTION_NAME, TOKEN_NAME)
    // OpenseaExtension(PROXY_REGISTERY_ADDRESS)
    {
        MetaDataStorageAddress = MetaDataStorage(_mdStorage);
        _contractMetadataURI = _metadataURI;
    }

    modifier isTokenOwner(uint256 tokenId) {
        require(ownerOf(tokenId) == owner(), "only owner");
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
        return _getPrice();
    }

    function setPublicSales(bool newValue) external onlyOwner {
        isPublicSalesOpen = newValue;
    }

    //
    // MINT AND BURN
    //

    function mint(uint256 day) public payable dateBounds(day) {
        require(isPublicSalesOpen, "Public sales are closed now");
        uint256 price = getAvailability(day);
        require(price > 0, "The token already taken");
        require(msg.value >= price, "No enough funds");

        _safeMint(msg.sender, day);
        MetaDataStorageAddress.setArt(day, address(this), day);
        MetaDataStorageAddress.setTokenURI(day, "");
        emit TokenMinted(day, msg.sender, price, false);
        _incrPriceMultiplier();
    }

    function burn(uint256 _tokenId) public virtual isTokenOwner(_tokenId) {
        require(_exists(_tokenId), "nonexistent token");
        transferFrom(msg.sender, owner(), _tokenId);
        _dropPriceMultiplier();
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

    //
    // ART AND META
    //
    function getArtPrice(address collection, uint256 artId)
        public
        view
        returns (uint256)
    {
        ERC721 collContract = ERC721(collection);

        address _owner = collContract.ownerOf(artId);
        if (_owner == msg.sender) {
            return SET_ART_PRICE_OWNER;
        } else {
            return 0;
        }
    }

    //
    // Request art change by user
    function setArt(
        uint256 tokenId,
        address collection,
        uint256 artId
    ) external payable {
        uint256 setArtPrice = getArtPrice(collection, artId);
        require(msg.value > 0, "You have to be an owner");
        require(msg.value >= setArtPrice, "not funds enough");
        MetaDataStorageAddress.setArt(tokenId, collection, artId);
        emit ArtUpdateRequested(tokenId, collection, artId);
    }

    function getArtHistory(uint256 tokenId)
        external
        view
        returns (ArtManager.ArtInfo[] memory)
    {
        return MetaDataStorageAddress.getArtHistory(tokenId);
    }

    function removeArt(uint256 tokenId, uint256 index) public onlyOwner {
        MetaDataStorageAddress.removeArt(tokenId, index);
    }

    // updating metadata by server
    function updateMetadata(uint256 tokenId, string memory metadataUrl)
        external
        onlyOwner
    {
        require(
            _exists(tokenId),
            "ERC721URIStorage: URI query for nonexistent token"
        );
        MetaDataStorageAddress.updateMetadata(tokenId, metadataUrl);
        emit MetadataSet(tokenId, metadataUrl);
    }

    function setTokenURI(uint256 _tokenId, string memory _tokenURI)
        external
        virtual
        onlyOwner
    {
        require(_exists(_tokenId), "URI set of nonexistent token");

        //TODO add art collection
        MetaDataStorageAddress.setTokenURI(_tokenId, _tokenURI);
    }

    function setDefaultMetadata(string memory newDMD) external onlyOwner {
        MetaDataStorageAddress.setDefaultMetadata(newDMD);
    }

    function withdrawRoyalties() external {
        emit RoyaltiesRequested({requester: msg.sender});
    }

    // --
    // Overrides
    // --

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
        string memory _uri = MetaDataStorageAddress.getTokenURI(_tokenId);
        if (bytes(_uri).length > 0) {
            return _uri;
        }
        super.tokenURI(_tokenId);
    }

    //
    // ADMIN AND SYSTEM
    //

    function setPriceMultiplier(uint256 newValue) public onlyOwner {
        _setPriceMultiplier(newValue);
    }

    function setContractURI(string memory newValue) public onlyOwner {
        _contractMetadataURI = newValue;
    }

    function contractURI() public view returns (string memory) {
        return _contractMetadataURI;
    }

    receive() external payable {}

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    //
    // OPENSEA
    //

    /**
     * Override isApprovedForAll to whitelist user's OpenSea proxy accounts to enable gas-less listings.
     */
    // function isApprovedForAll(address owner, address operator)
    //     public
    //     view
    //     virtual
    //     override
    //     returns (bool)
    // {
    //     _isApprovedForAll(owner, operator);
    //     return super.isApprovedForAll(owner, operator);
    // }

    /**
     * This is used instead of msg.sender as transactions won't be sent by the original token owner, but by OpenSea.
     */
    // function _msgSender() internal view override returns (address sender) {
    //     return __msgSender();
    // }
    // OpenSea
    // function setProxyRegistry(address proxyAddress) public onlyOwner {
    //     _setProxyRegistry(proxyAddress);
    // }

    //
    // SUPPORT INTERFACE
    //

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
            // interfaceId == type(IERC2981).interfaceId ||
            super.supportsInterface(interfaceId);
        // if (interfaceId == LibRoyaltiesV2._INTERFACE_ID_ROYALTIES) {
        //     return true;
        // }
        // return super.supportsInterface(interfaceId);
    }
}
