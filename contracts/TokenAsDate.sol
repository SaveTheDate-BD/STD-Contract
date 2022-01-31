// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

abstract contract TokenAsDate {
    uint256 private constant _halfTokensAmount = 5000000; // 13698 years
    uint256 private constant _secondsInDay = 60 * 60 * 24;
    uint256 private _priceBase = 10**16; // 0.01Eth
    uint256 private _futurePriceMultiplier = 100; // 10Eth
    uint256 private _basePriceStep = 10**15; // 0.001Eth 1 eth for 1000 purchases
    uint32 private _basePriceStepMultiplier = 0;
    uint256 private _futureDay = 7; //days

    modifier dateBounds(uint256 day) {
        require(day >= 0 && day <= _halfTokensAmount * 2, "Out of date bounds");
        _;
    }

    function _getCurrentDay() internal view returns (uint256) {
        return (block.timestamp / _secondsInDay) + _halfTokensAmount;
    }

    function _getPastPrice() internal view returns (uint256) {
        return _priceBase + (_basePriceStep * _basePriceStepMultiplier);
    }

    function setBasePriceStepMultiplier(uint256 newValue) public virtual {
        _basePriceStep = newValue;
    }

    function setFuturePriceMultiplier(uint256 newValue) public virtual {
        _futurePriceMultiplier = newValue;
    }

    function setFutureDay(uint256 newValue) public virtual {
        _futureDay = newValue;
    }

    function _getFuturePrice() internal view returns (uint256) {
        return _getPastPrice() * _futurePriceMultiplier;
    }

    function _getFutureDay() internal view returns (uint256) {
        return _futureDay;
    }
}
