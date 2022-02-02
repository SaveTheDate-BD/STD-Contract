// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;
import "./openzeppelin/token/ERC721/ERC721.sol";
import "hardhat/console.sol";

abstract contract ArtManager {
    constructor() {}

    struct ArtInfo {
        address owner;
        address collection;
        uint256 artTokenId;
        string url;
    }

    mapping(uint256 => ArtInfo[]) private _tokenArtHistory;
    mapping(uint256 => uint256) private _tokenActiveArt;

    function _setArt(
        uint256 tokenId,
        address collection,
        uint256 artId
    ) internal {
        ERC721 collContract = ERC721(collection);
        address _owner = collContract.ownerOf(artId);
        ArtInfo memory artInfo = ArtInfo({
            owner: _owner,
            collection: collection,
            artTokenId: artId,
            url: ""
        });
        console.log("set art:", _tokenArtHistory[tokenId].length);
        _tokenArtHistory[tokenId].push(artInfo);
        _tokenActiveArt[tokenId] = _tokenArtHistory[tokenId].length - 1;
        console.log("set art_:", _tokenArtHistory[tokenId].length);
        console.log("set art+_:", tokenId, _tokenActiveArt[tokenId]);
    }

    function _updateMetadata(uint256 tokenId, string memory metadataUrl)
        internal
    {
        require(
            _tokenArtHistory[tokenId].length > 0,
            "history should not be empty"
        );
        string memory url = _tokenArtHistory[tokenId][_tokenActiveArt[tokenId]]
            .url;
        console.log(" art up:", _tokenActiveArt[tokenId]);
        console.log(" art up_:", url, ":", bytes(url).length);
        // rewrite protection
        require(bytes(url).length == 0, "Metadata is immutable");
        // write
        _tokenArtHistory[tokenId][_tokenActiveArt[tokenId]].url = metadataUrl;
    }

    function _removeArt(uint256 tokenId, uint256 index) internal {
        // Remove art from history
        _removeElementFromArray(index, _tokenArtHistory[tokenId]);
        // if was active
        if (index == _tokenActiveArt[tokenId]) {
            if (_tokenArtHistory[tokenId].length > 0) {
                _tokenActiveArt[tokenId] = _tokenArtHistory[tokenId].length - 1;
            } else {
                delete _tokenActiveArt[tokenId];
            }
        }
    }

    function _getCurrentArt(uint256 tokenId)
        internal
        view
        returns (ArtInfo storage)
    {
        return _tokenArtHistory[tokenId][_tokenActiveArt[tokenId]];
    }

    function getCurrentArt(uint256 tokenId)
        public
        view
        returns (ArtInfo memory)
    {
        return _getCurrentArt(tokenId);
    }

    function getArtHistory(uint256 tokenId)
        external
        view
        returns (ArtInfo[] memory)
    {
        return _tokenArtHistory[tokenId];
    }

    function _changeActiveArt(uint256 tokenId, uint256 newIndex)
        internal
        returns (string memory)
    {
        require(
            _tokenArtHistory[tokenId].length > 0,
            "history should not be empty"
        );
        require(
            newIndex < _tokenArtHistory[tokenId].length && newIndex >= 0,
            "index outbounds"
        );
        _tokenActiveArt[tokenId] = newIndex;
        return _tokenArtHistory[tokenId][_tokenActiveArt[tokenId]].url;
    }

    function _removeElementFromArray(uint256 index, ArtInfo[] storage array)
        internal
        returns (ArtInfo[] memory)
    {
        require(index < array.length, "Out of bounds");

        for (uint256 i = index; i < array.length - 1; i++) {
            array[i] = array[i + 1];
        }
        array.pop();
        return array;
    }
}
