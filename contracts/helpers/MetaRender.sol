// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
import "hardhat/console.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

contract MetaRender is ChainlinkClient {
    using Chainlink for Chainlink.Request;
    event Fulfillmr(uint256 indexed _tokenId, string indexed _url);
    event MetadataRequested(uint256 day);
    string public url;

    address private oracle;
    bytes32 private jobId;
    uint256 private fee;

    address[] availableVisualizers;
    address defaultVisualizer;

    mapping(uint256 => address) _visByTokenId;

    constructor() {
        setPublicChainlinkToken();
    }

    function requestMetaData(uint256 day) public returns (bytes32 requestId) {
        emit MetadataRequested(day);
    }

    function setDefaultVisualizer(address va) public {
        //TODO Only owner
        defaultVisualizer = va;
    }

    function addVisualizer(address va) public {
        //TODO Only owner
        availableVisualizers.push(va);
    }
}
