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
        uint256 tokenId;
        string artId;
        address publisher;
        address owner;
        address collection;
        uint256 artTokenId;
        string url;
    }

    mapping(uint256 => ArtInfo[]) private _tokenArtHistory;
    mapping(uint256 => ArtInfo) private _tokenActiveArt;

    function _setArt(
        uint256 tokenId,
        string memory changeId,
        address publisher
    ) internal {
        emit MetadataUpdateRequested(tokenId, changeId, publisher);
    }

    function _updateArt(
        uint256 tokenId,
        string memory artId,
        address publisher,
        address owner,
        address collection,
        uint256 artTokenId,
        string memory artUrl
    ) internal {
        ArtInfo memory artInfo = ArtInfo({
            tokenId: tokenId,
            artId: artId,
            publisher: publisher,
            owner: owner,
            collection: collection,
            artTokenId: artTokenId,
            url: artUrl
        });
        _tokenArtHistory[tokenId].push(artInfo);
        _tokenActiveArt[tokenId] = artInfo;
    }

    function _getArtId(address collection, string memory artTokenId)
        private
        pure
        returns (string memory)
    {
        return string(abi.encodePacked(collection, ":", artTokenId));
    }

    function _removeArt(
        uint256 tokenId,
        address artCollectionAddress,
        string memory artTokenId
    ) internal {
        ArtInfo[] storage tokenHistory = _tokenArtHistory[tokenId];
        string memory artId = _getArtId(artCollectionAddress, artTokenId);
        // Remove art from history
        for (uint256 i = 0; i < tokenHistory.length; i++) {
            if (_compareStrings(tokenHistory[i].artId, artId)) {
                _removeElementFromArray(i, tokenHistory);
                break;
            }
        }
        // upadte the active art
        if (
            _tokenActiveArt[tokenId].publisher != address(0) &&
            _compareStrings(_tokenActiveArt[tokenId].artId, artId)
        ) {
            if (tokenHistory.length > 0) {
                _tokenActiveArt[tokenId] = tokenHistory[
                    tokenHistory.length - 1
                ];
            } else {
                delete _tokenActiveArt[tokenId];
            }
        }
    }

    function _getCurrentArt(uint256 tokenId)
        internal
        view
        returns (ArtInfo memory)
    {
        return _tokenActiveArt[tokenId];
    }

    function _royaltyInfo(uint256 tokenId, uint256 salePrice)
        internal
        view
        returns (address receiver, uint256 royaltyAmount)
    {
        ArtInfo memory ai = _tokenActiveArt[tokenId];
        royaltyAmount = salePrice / 10000;
        receiver;
        if (ai.owner == address(0)) {
            receiver = address(this);
        } else {
            receiver = ai.owner;
        }
        return (receiver, royaltyAmount); //10%
    }

    // --
    // HELPERS
    // --
    function _compareStrings(string memory a, string memory b)
        internal
        pure
        returns (bool)
    {
        bool result = keccak256(abi.encodePacked(a)) ==
            keccak256(abi.encodePacked(b));
        return result;
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

    function _withdrawRoyalties() internal {
        emit RoyaltiesRequested({requester: msg.sender});
    }
}
