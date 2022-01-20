// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library FinanceMath {
    uint256 constant artistShareFirstComm = 8000; //80%
    uint256 constant artistShareSecondComm = 1500; //15%
    uint256 constant artistShareFirstCharity = 1900; //19%
    uint256 constant artistShareSecondCharity = 1500; //15%

    uint256 constant serviceShareFirstComm = 2000; //20%
    uint256 constant serviceShareSecondComm = 500; //5%
    uint256 constant serviceShareFirstCharity = 200; //2%
    uint256 constant serviceShareSecondCharity = 500; //5%

    uint256 constant defaultFundFirstShare = 7900; //79%

    // uint256 constant defaultFundSecondShare = 500; //5% /// NOT IMPLEMENTED

    function calcProfit(
        uint256 sum,
        bool isFirstSale,
        bool isCharitySale
    )
        internal
        returns (
            uint256 service,
            uint256 artist,
            uint256 fund
        )
    {
        uint256 artistShare;
        uint256 serviceShare;
        uint256 fundShare;
        if (isCharitySale) {
            if (isFirstSale) {
                artistShare = artistShareFirstCharity;
                serviceShare = serviceShareFirstCharity;
                fundShare = defaultFundFirstShare;
            } else {
                artistShare = artistShareSecondCharity;
                serviceShare = serviceShareSecondCharity;
                fundShare = 0;
            }
        } else {
            if (isFirstSale) {
                artistShare = artistShareFirstComm;
                serviceShare = serviceShareFirstComm;
                fundShare = 0;
            } else {
                artistShare = artistShareSecondComm;
                serviceShare = serviceShareSecondComm;
                fundShare = 0;
            }
        }
        require(
            artistShare + serviceShare + fundShare == 10000,
            "Shares sum should be 100%"
        );
        artist = (sum * artistShare) / 10000;
        service = (sum * serviceShare) / 10000;
        fund = (sum * fundShare) / 10000;
        return (artist, service, fund);
    }
}
