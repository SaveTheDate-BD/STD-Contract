// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721URIStorage.sol)

pragma solidity ^0.8.0;

import "./openzeppelin/access/Ownable.sol";
import "./ArtManager.sol";

contract MetaDataStorage is Ownable, ArtManager {
    mapping(uint256 => string) private _tokenURIs;

    function getTokenURI(uint256 tokenId)
        external
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

    function clearTokenURI(uint256 tokenId) external {
        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}
