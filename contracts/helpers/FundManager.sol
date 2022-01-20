// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721URIStorage.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC721 token with storage based token URI management.
 */
abstract contract FundManager {
    constructor() {}

    uint256 constant minWithdrawAmount = 10**16; // 0.01eth
    event FundWithdrawn(address receiver, uint256 amount);

    mapping(address => uint256) private _fundBalances;
    uint256 private totalBalance = 0;

    function _addFund(address receiverFund, uint256 amount) private {
        require(amount > 0, "amount should be grather then 0");
        require(receiverFund != address(0), "receiver should be a zero");
        _fundBalances[receiverFund] = _fundBalances[receiverFund] + amount;
        totalBalance = totalBalance + amount;
    }

    function _withdrawFund() private {
        uint256 balance = _fundBalances[msg.sender];
        require(balance >= minWithdrawAmount, "No funds enough");
        payable(msg.sender).transfer(balance);
        emit FundWithdrawn({receiver: msg.sender, amount: balance});
        _fundBalances[msg.sender] = 0;
        totalBalance = totalBalance - balance;
    }

    function _getFundBalance() private view returns (uint256) {
        return totalBalance;
    }
}
