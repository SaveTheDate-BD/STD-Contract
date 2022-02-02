// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "./openzeppelin/access/Ownable.sol";
import "./ArtManager.sol";
import "hardhat/console.sol";

contract MetaDataStorage is Ownable, ArtManager {
    // mapping(uint256 => string) private _tokenURIs;
    string defaultMeta =
        '{"name":"BigDay [Minting...]", "description":"Minting in progress. Please, stand by."}';

    function getTokenURI(uint256 tokenId)
        external
        view
        onlyOwner
        returns (string memory)
    {
        ArtInfo storage ca = _getCurrentArt(tokenId);
        return ca.url;
    }

    function updateMetadata(uint256 tokenId, string memory metadataUrl)
        external
        onlyOwner
    {
        _updateMetadata(tokenId, metadataUrl);
    }

    function removeArt(uint256 tokenId, uint256 index) external onlyOwner {
        _removeArt(tokenId, index);
    }

    function setArt(
        uint256 tokenId,
        address collection,
        uint256 artId
    ) external onlyOwner {
        _setArt(tokenId, collection, artId);
    }

    function setTokenURI(uint256 tokenId, string memory _tokenURI)
        external
        onlyOwner
    {
        ArtInfo storage ca = _getCurrentArt(tokenId);
        if (bytes(_tokenURI).length == 0) {
            ca.url = defaultMeta;
        } else {
            ca.url = _tokenURI;
        }
    }

    function changeActiveArt(uint256 tokenId, uint256 newIndex)
        external
        onlyOwner
    {
        _changeActiveArt(tokenId, newIndex);
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
