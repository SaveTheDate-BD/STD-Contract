// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract ArtManager {
    constructor() {}

    event MetadataUpdateRequested(
        uint256 tokenId,
        string changeId,
        address publisher
    );

    event RoyaltiesRequested(address requester);

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
        string memory changeId,
        address publisher
    ) internal {
        emit MetadataUpdateRequested(tokenId, changeId, publisher);
    }

    function _updateArt(
        uint256 tokenId,
        address owner,
        address collection,
        uint256 artTokenId,
        string memory artUrl
    ) internal {
        ArtInfo memory artInfo = ArtInfo({
            owner: owner,
            collection: collection,
            artTokenId: artTokenId,
            url: artUrl
        });
        _tokenArtHistory[tokenId].push(artInfo);
        _tokenActiveArt[tokenId] = _tokenArtHistory[tokenId].length - 1;
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

    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount)
    {
        if (
            _tokenArtHistory[tokenId][_tokenActiveArt[tokenId]].owner ==
            address(0)
        ) {
            receiver = address(this);
        } else {
            receiver = _tokenArtHistory[tokenId][_tokenActiveArt[tokenId]]
                .owner;
        }
        return (receiver, salePrice / 10000); //10%
    }

    // --
    // HELPERS
    // --
    // function _compareStrings(string memory a, string memory b)
    //     internal
    //     pure
    //     returns (bool)
    // {
    //     bool result = keccak256(abi.encodePacked(a)) ==
    //         keccak256(abi.encodePacked(b));
    //     return result;
    // }

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
