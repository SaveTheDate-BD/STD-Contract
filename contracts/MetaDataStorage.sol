// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721URIStorage.sol)

pragma solidity ^0.8.0;

abstract contract MetaDataStorage {
    mapping(uint256 => string) private _tokenURIs;

    function _getTokenURI(uint256 tokenId)
        internal
        view
        virtual
        returns (string memory)
    {
        if (bytes(_tokenURIs[tokenId]).length > 0) {
            return string(_tokenURIs[tokenId]);
        }
        return "";
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI)
        internal
        virtual
    {
        _tokenURIs[tokenId] = _tokenURI;
    }

    function _clearTokenURI(uint256 tokenId) internal {
        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}
