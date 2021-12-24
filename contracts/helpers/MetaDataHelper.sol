// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../Vis/Vis.sol";
import "./base64-sol/base64.sol";
import "./DateUtils2/DateTimeLibrary.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

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

    function convertDayToString(uint256 day)
        internal
        pure
        returns (string memory)
    {
        uint256 y;
        uint256 m;
        uint256 d;
        (y, m, d) = DateTimeLibrary._daysToDate(day * 60 * 60 * 24);
        return
            string(
                abi.encodePacked(
                    Strings.toString(y),
                    "-",
                    Strings.toString(m),
                    "-",
                    Strings.toString(d)
                )
            );
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
