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
        oracle = 0x718Cc73722a2621De5F2f0Cb47A5180875f62D60;
        jobId = "86b489ec4d84439c96181a8df7b22223";
        fee = 0.1 * 10**18;
    }

    function requestMetaData(uint256 day) public returns (bytes32 requestId) {
        Chainlink.Request memory request = buildChainlinkRequest(
            jobId,
            address(this),
            this._fulfill.selector
        );
        request.addUint("seed", day);
        console.log("Meta3Data requested");
        emit MetadataRequested(day);
        // Sends the request
        return sendChainlinkRequestTo(oracle, request, fee);
    }

    function _fulfill(
        bytes32 _requestId,
        address _receiver,
        uint256 _tokenId,
        string memory _url
    ) public recordChainlinkFulfillment(_requestId) {
        console.log("MR _fulfill url", _tokenId, _url);
        emit Fulfillmr(_tokenId, _url);
        fulfill(_requestId, _receiver, _tokenId, _url);
    }

    function fulfill(
        bytes32 _requestId,
        address, // _receiver,
        uint256 _tokenId,
        string memory _url
    ) public virtual recordChainlinkFulfillment(_requestId) {
        // url = _url;
        console.log("MR fulfill url", _tokenId, _url);
        // super._safeMint(tokenId, _url);
        Fulfillmr(_tokenId, _url);
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
