// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

abstract contract PublicSales {
    bool private _privateSalesIsOpened = false;

    function setPrivateSales(bool newValue) public virtual {
        _privateSalesIsOpened = newValue;
    }

    function isPrivateSalesOpened() public view returns (bool) {
        return _privateSalesIsOpened;
    }
}
