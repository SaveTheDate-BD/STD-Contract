// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "base64-sol/base64.sol";

contract TheDate is ERC721URIStorage, Ownable {
    // uint256 public tokenCounter;
    event CreatedSVGNFT(uint256 indexed tokenId, string tokenURI);

    constructor() ERC721("SAVE THE DATE", "STD") {
        // tokenCounter = 0;
    }

    function create(uint256 day) public {
        _safeMint(msg.sender, day);
        string memory svg = "";
        // string memory imageURI = svgToImageURI(svg);
        // _setTokenURI(day, formatTokenURI(imageURI));
        // emit CreatedSVGNFT(day, svg);
    }

    function formatTokenURI(string memory imageURI)
        public
        pure
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                "SVG NFT", // You can add whatever name here
                                '", "description":"An NFT based on SVG!", "attributes":"", "image":"',
                                imageURI,
                                '"}'
                            )
                        )
                    )
                )
            );
    }
}
