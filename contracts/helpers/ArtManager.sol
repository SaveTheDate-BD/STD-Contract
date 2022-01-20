// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev ERC721 token with storage based token URI management.
 */
abstract contract ArtManager {
    constructor() {}

    event MetadataUpdateRequested(
        uint256 tokenId,
        string changeId,
        address publisher
    );
    struct ArtInfo {
        address publisher;
        string url;
    }
    mapping(uint256 => ArtInfo[]) private _tokenArtHistory;
    mapping(uint256 => ArtInfo) private _tokenActiveArt;

    // TODO payable
    function _requestArtChange(
        uint256 tokenId,
        string memory changeId,
        address publisher
    ) internal {
        emit MetadataUpdateRequested(tokenId, changeId, publisher);
    }

    function _updateArt(
        uint256 tokenId,
        string memory artUrl,
        address publisher
    ) public {
        ArtInfo[] storage tokenHistory = _tokenArtHistory[tokenId];
        ArtInfo memory artInfo = ArtInfo({publisher: publisher, url: artUrl});
        tokenHistory.push(artInfo);
        _tokenActiveArt[tokenId] = artInfo;
    }

    function compareStrings(string memory a, string memory b)
        internal
        pure
        returns (bool)
    {
        bool result = keccak256(abi.encodePacked(a)) ==
            keccak256(abi.encodePacked(b));
        return result;
    }

    function removeElementFromArray(uint256 index, ArtInfo[] storage array)
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

    function _removeArt(uint256 tokenId, string memory artUrl) internal {
        ArtInfo[] storage tokenHistory = _tokenArtHistory[tokenId];
        // Remove art from history
        for (uint256 i = 0; i < tokenHistory.length; i++) {
            if (compareStrings(tokenHistory[i].url, artUrl)) {
                // delete tokenHistory[i];
                removeElementFromArray(i, tokenHistory);
                break;
            }
        }
        // upadte the active art
        if (
            _tokenActiveArt[tokenId].publisher != address(0) &&
            compareStrings(_tokenActiveArt[tokenId].url, artUrl)
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

    function getCurrentArt(uint256 tokenId)
        public
        view
        returns (ArtInfo memory)
    {
        return _tokenActiveArt[tokenId];
    }
}
