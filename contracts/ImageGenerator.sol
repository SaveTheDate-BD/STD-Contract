// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "base64-sol/base64.sol";

contract ImageGenerator {
    string internal mainSvg1;
    string internal mainSvg2;

    constructor() {
        mainSvg1 = '<svg xmlns="http://www.w3.org/2000/svg" width="467" height="462">  <rect x="80" y="60" width="250" height="250" rx="20"      style="fill:';
        mainSvg2 = ' ; stroke:#000000;stroke-width:2px;" />    <rect x="140" y="120" width="250" height="250" rx="40"      style="fill:#0000ff; stroke:#000000; stroke-width:2px;      fill-opacity:0.7;" /></svg>';
    }

    function generate(string memory color) public view returns (string memory) {
        string memory result = string(
            abi.encodePacked(mainSvg1, color, mainSvg2)
        );
        return svgToImageURI(result);
    }

    function svgToImageURI(string memory svg)
        public
        pure
        returns (string memory)
    {
        // example:
        // <svg width='500' height='500' viewBox='0 0 285 350' fill='none' xmlns='http://www.w3.org/2000/svg'><path fill='black' d='M150,0,L75,200,L225,200,Z'></path></svg>
        // data:image/svg+xml;base64,PHN2ZyB3aWR0aD0nNTAwJyBoZWlnaHQ9JzUwMCcgdmlld0JveD0nMCAwIDI4NSAzNTAnIGZpbGw9J25vbmUnIHhtbG5zPSdodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2Zyc+PHBhdGggZmlsbD0nYmxhY2snIGQ9J00xNTAsMCxMNzUsMjAwLEwyMjUsMjAwLFonPjwvcGF0aD48L3N2Zz4=
        string memory baseURL = "data:image/svg+xml;base64,";
        string memory svgBase64Encoded = Base64.encode(
            bytes(string(abi.encodePacked(svg)))
        );
        return string(abi.encodePacked(baseURL, svgBase64Encoded));
    }
}
