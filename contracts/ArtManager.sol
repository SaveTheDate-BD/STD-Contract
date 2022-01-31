// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;
import "./openzeppelin/token/ERC721/ERC721.sol";

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
    event TestTest(uint256 indx);

    function _setArt(
        uint256 tokenId,
        address collection,
        uint256 artId
    ) internal {
        ERC721 collContract = ERC721(collection);
        address _owner = collContract.ownerOf(tokenId);
        ArtInfo memory artInfo = ArtInfo({
            owner: _owner,
            collection: collection,
            artTokenId: artId,
            url: ""
        });
        emit TestTest(_tokenArtHistory[tokenId].length);
        _tokenArtHistory[tokenId].push(artInfo);
        emit TestTest(_tokenArtHistory[tokenId].length);
        _tokenActiveArt[tokenId] = _tokenArtHistory[tokenId].length - 1;
    }

    function _updateMetadata(
        uint256 tokenId,
        string memory metadataUrl,
        bool force
    ) internal {
        require(
            _tokenArtHistory[tokenId].length > 0,
            "history should not be empty"
        );
        string memory url = _tokenArtHistory[tokenId][_tokenActiveArt[tokenId]]
            .url;
        // rewrite protection
        require(bytes(url).length == 0, "Metadata is immutable");
        // write
        _tokenArtHistory[tokenId][_tokenActiveArt[tokenId]].url = metadataUrl;
    }

    function _removeArt(
        uint256 tokenId,
        address artCollectionAddress,
        uint256 artTokenId
    ) internal {
        // Remove art from history
        for (uint256 i = 0; i < _tokenArtHistory[tokenId].length; i++) {
            if (
                _tokenArtHistory[tokenId][i].artTokenId == artTokenId &&
                artCollectionAddress == _tokenArtHistory[tokenId][i].collection
            ) {
                _removeElementFromArray(i, _tokenArtHistory[tokenId]);
                break;
            }
        }
        // upadte the active art
        if (
            _tokenArtHistory[tokenId][_tokenActiveArt[tokenId]].collection !=
            address(0) &&
            _tokenArtHistory[tokenId][_tokenActiveArt[tokenId]].artTokenId ==
            artTokenId &&
            artCollectionAddress ==
            _tokenArtHistory[tokenId][_tokenActiveArt[tokenId]].collection
        ) {
            if (_tokenArtHistory[tokenId].length > 0) {
                _tokenActiveArt[tokenId] = _tokenArtHistory[tokenId].length - 1;
            } else {
                delete _tokenActiveArt[tokenId];
            }
        }
    }

    function getCurrentArt(uint256 tokenId) external view returns (uint256) {
        return _tokenActiveArt[tokenId];
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
