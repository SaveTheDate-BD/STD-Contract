// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

abstract contract LooksrareExtension {
    constructor(
        string memory _name,
        string memory _symbol,
        address _proxyRegistryAddress
    ) {
        proxyRegistryAddress = _proxyRegistryAddress;
    }
}
