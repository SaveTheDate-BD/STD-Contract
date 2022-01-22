// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./helpers/opensea/meta-transactions/ContentMixin.sol";
import "./helpers/opensea/meta-transactions/NativeMetaTransaction.sol";

contract OwnableDelegateProxy {}

/**
 * Used to delegate ownership of a contract to another address, to save on unneeded transactions to approve contract use for users
 */
contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}

abstract contract OpenseaExtension is ContextMixin, NativeMetaTransaction {
    using SafeMath for uint256;
    address proxyRegistryAddress;

    constructor(address _proxyRegistryAddress) {
        proxyRegistryAddress = _proxyRegistryAddress;
    }

    function _setProxyRegistry(address _proxyRegistryAddress) internal {
        proxyRegistryAddress = _proxyRegistryAddress;
    }

    /**
     * Override isApprovedForAll to whitelist user's OpenSea proxy accounts to enable gas-less listings.
     */
    function _isApprovedForAll(address owner, address operator)
        internal
        view
        returns (bool)
    {
        // Whitelist OpenSea proxy contract for easy trading.
        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        if (address(proxyRegistry.proxies(owner)) == operator) {
            return true;
        }
    }

    /**
     * This is used instead of msg.sender as transactions won't be sent by the original token owner, but by OpenSea.
     */
    function __msgSender() internal view returns (address sender) {
        return ContextMixin.msgSender();
    }
}
