// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// Ownable
contract PaymentRecievers {
    // Mapping owner address to token count
    // address payable[] receivers;
    mapping(address => bool) _receivers;
    mapping(address => uint256) _indexes;
    address[] _addresses;

    constructor() {}

    function addReceiver(address receiver) public {
        _indexes[receiver] = _addresses.length;
        _addresses.push(receiver);
        _receivers[receiver] = true;
    }

    function getReceivers() public view returns (address[] memory) {
        return _addresses;
    }

    function removeReceiver(address receiver) public {
        // require(receivers[_id].send, "Person does not exist.");

        require(_receivers[receiver]);
        delete _addresses[_indexes[receiver]];
        delete _indexes[receiver];
        delete _receivers[receiver];
    }

    function withdraw(address receiver, uint256 amount) public {
        require(_receivers[receiver]);
        require(receiver != address(0));
        //TODO onlyowner
        payable(receiver).transfer(amount);
    }
}
