// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../Vis/Vis.sol";
import "./base64-sol/base64.sol";
import "./dateUtils/DateUtils.sol";

// import "./DateUtils.sol";
contract MetaDataHelper {
    address[] availableVisualizers;
    address defaultVisualizer;

    mapping(uint256 => address) _visByTokenId;

    function setDefaultVisualizer(address va) public {
        //TODO Only owner
        defaultVisualizer = va;
    }

    function addVisualizer(address va) public {
        //TODO Only owner
        availableVisualizers.push(va);
    }

    function setVisToToken(uint256 day, uint256 visId) public {
        _visByTokenId[day] = availableVisualizers[visId];
    }

    function uint2str(uint256 _i)
        internal
        pure
        returns (string memory _uintAsString)
    {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len - 1;
        while (_i != 0) {
            bstr[k--] = bytes1(uint8(48 + (_i % 10)));
            _i /= 10;
        }
        return string(bstr);
    }

    function convertDayToString(uint256 day)
        internal
        pure
        returns (string memory)
    {
        return DateUtils.convertTimestampToDateTimeString(day * 1000 * 60 * 60);
    }

    function getDateDesc(uint256 day) public pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "The day #",
                    convertDayToString(day),
                    " NFT desc"
                )
            );
    }

    function getDateName(uint256 day) public pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "The day #",
                    convertDayToString(day),
                    " NFT name"
                )
            );
    }

    function getDateImage(uint256 day) public view returns (string memory) {
        SaveDateVisualiser Viser = SaveDateVisualiser(defaultVisualizer);
        return Viser.render(day);
    }

    function formatTokenURI(
        string memory imageURI,
        string memory _name,
        string memory _desc
    ) public pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                _name, // You can add whatever name here
                                '", "description":"',
                                _desc,
                                '", "attributes":"", "image":"',
                                imageURI,
                                '"}'
                            )
                        )
                    )
                )
            );
    }
}
