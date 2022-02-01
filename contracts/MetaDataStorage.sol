// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "./openzeppelin/access/Ownable.sol";
import "./ArtManager.sol";
import "hardhat/console.sol";

contract MetaDataStorage is Ownable, ArtManager {
    mapping(uint256 => string) private _tokenURIs;
    string defaultMeta =
        '{"name":"BigDay [Minting...]", "description":"Minting in progress. Please, stand by."}';

    function getTokenURI(uint256 tokenId)
        external
        view
        onlyOwner
        returns (string memory)
    {
        return _tokenURIs[tokenId];
    }

    function updateMetadata(uint256 tokenId, string memory metadataUrl)
        external
        onlyOwner
    {
        _updateMetadata(tokenId, metadataUrl);
        _tokenURIs[tokenId] = metadataUrl;
    }

    function removeArt(
        uint256 tokenId,
        address collection,
        uint256 artId
    ) external onlyOwner {
        _removeArt(tokenId, collection, artId);
    }

    function setArt(
        uint256 tokenId,
        address collection,
        uint256 artId
    ) external onlyOwner {
        _setArt(tokenId, collection, artId);
    }

    function clearTokenURI(uint256 tokenId) external onlyOwner {
        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }

    function setTokenURI(uint256 tokenId, string memory _tokenURI)
        external
        onlyOwner
    {
        if (bytes(_tokenURI).length == 0) {
            _tokenURIs[tokenId] = defaultMeta;
        } else {
            _tokenURIs[tokenId] = _tokenURI;
        }
    }

    function changeActiveArt(uint256 tokenId, uint256 newIndex)
        external
        onlyOwner
    {
        _tokenURIs[tokenId] = _changeActiveArt(tokenId, newIndex);
    }

    function setDefaultMetadata(string memory newDMD) external onlyOwner {
        defaultMeta = newDMD;
    }

    function transferOwnership(address newOwner) public override onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        super.transferOwnership(newOwner);
    }
}
