// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721URIStorage.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC721 token with storage based token URI management.
 */
abstract contract RoyaltiesManager {
    constructor() {}

    uint256 constant minWithdrawAmount = 10**16; // 0.01eth
    event RoyaltiesWithdrawn(address receiver, uint256 amount);
    struct Shares {
        uint16 service;
        uint16 artists;
        uint16 funds;
    }

    mapping(address => uint256) private _royatiesBalances;
    mapping(uint256 => Shares) private _royatiesShares;
    uint256 private totalBalance = 0;

    function _addRoyalties(address receiver, uint256 amount) private {
        require(amount > 0, "amount should be grather then 0");
        require(receiver != address(0), "receiver should be a zero");
        _royatiesBalances[receiver] = _royatiesBalances[receiver] + amount;
        totalBalance = totalBalance + amount;
    }

    function _withdrawRoyalties() private {
        uint256 balance = _royatiesBalances[msg.sender];
        require(balance >= minWithdrawAmount, "No funds enough");
        payable(msg.sender).transfer(balance);
        emit RoyaltiesWithdrawn({receiver: msg.sender, amount: balance});
        _royatiesBalances[msg.sender] = 0;
        totalBalance = totalBalance - balance;
    }

    function _getRoyaliesBalance() private view returns (uint256) {
        return totalBalance;
    }
}
