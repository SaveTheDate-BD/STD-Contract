// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
import "./openzeppelin/utils/math/SafeMath.sol";

abstract contract TokenAsDate {
    uint256 private constant _halfTokensAmount = 5000000; // 13698 years
    uint256 private constant _secondsInDay = 60 * 60 * 24;
    uint256 private _priceBase = 10**16; // 0.01Eth
    uint256 private _basePriceStep = 10**15; // 0.001Eth 1 eth for 1000 purchases
    uint256 private _basePriceStepMultiplier = 0;
    uint256 private _futureDay = 7; //days
    using SafeMath for uint256;
    modifier dateBounds(uint256 day) {
        require(day >= 0 && day <= _halfTokensAmount * 2, "Out of date bounds");
        _;
    }

    function _getPrice() internal view returns (uint256) {
        return _priceBase + (_basePriceStep * _basePriceStepMultiplier);
    }

    function _incrPriceMultiplier() internal {
        _basePriceStepMultiplier = _basePriceStepMultiplier + 1;
    }

    function _dropPriceMultiplier() internal {
        _basePriceStepMultiplier = _basePriceStepMultiplier.div(10).mul(9);
        if (_basePriceStepMultiplier < _priceBase) {
            _basePriceStepMultiplier = _priceBase;
        }
    }

    function _setPriceMultiplier(uint256 newValue) internal {
        _priceBase = _getPrice();
        _basePriceStepMultiplier = 0;
        _basePriceStep = newValue;
    }
}
