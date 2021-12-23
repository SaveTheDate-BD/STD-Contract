// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./Vis.sol";

contract SaveDateVisCaller {
    address visualizatorAddress;

    function setVisCallee(address va) public {
        //TODO Only owner
        visualizatorAddress = va;
    }

    function getDateDesc(uint256 day) view returns (string memory) {
        return string(abi.encodePacked("The day #", day, " NFT desc"));
    }

    function getDateName(uint256 day) view returns (string memory) {
        return string(abi.encodePacked("The day #", day, " NFT name"));
    }

    function getDateImage(uint256 memory day)
        public
        view
        returns (string memory)
    {
        SaveDateVisualiser Viser = SaveDateVisualiser(visualizatorAddress);
        return Viser.render(day);
    }
}
