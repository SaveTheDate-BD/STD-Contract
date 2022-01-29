// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721URIStorage.sol)

pragma solidity ^0.8.0;

import "./openzeppelin/access/Ownable.sol";
import "./ArtManager.sol";

contract MetaDataStorage is Ownable, ArtManager {
    mapping(uint256 => string) private _tokenURIs;

    function getTokenURI(uint256 tokenId)
        internal
        view
        returns (string memory)
    {
        if (bytes(_tokenURIs[tokenId]).length > 0) {
            return string(_tokenURIs[tokenId]);
        }
        return "";
    }

    function setTokenURI(uint256 tokenId, string memory _tokenURI) external {
        _tokenURIs[tokenId] = _tokenURI;
    }

    function updateArt(
        uint256 tokenId,
        address owner,
        address collection,
        uint256 artTokenId,
        string memory metaUrl
    ) external {
        _tokenURIs[tokenId] = metaUrl;
        _updateArt(tokenId, owner, collection, artTokenId, metaUrl);
    }

    function removeArt(
        uint256 tokenId,
        address collection,
        uint256 artId
    ) external {
        _removeArt(tokenId, collection, artId);
    }

    function setArt(
        uint256 tokenId,
        string memory changeId,
        address publisher
    ) external {
        _setArt(tokenId, changeId, publisher);
    }

    function clearTokenURI(uint256 tokenId) external {
        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }

    function transferOwnership(address newOwner) public override onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        super.transferOwnership(newOwner);
    }
}
