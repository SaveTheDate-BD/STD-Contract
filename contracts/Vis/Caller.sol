// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "../base64-sol/base64.sol";
import "./Vis.sol";

contract SaveDateCaller {
    address callee;

    function setCallee(address c) public {
        callee = c;
    }

    function createImage(string memory text)
        public
        view
        returns (string memory)
    {
        SaveDateVisualiser Viser = SaveDateVisualiser(callee);
        return Viser.render(text);
    }
}
