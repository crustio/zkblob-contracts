// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract DAS is AccessControl {
    bytes32 public constant DAS_NODE_ROLE = keccak256("DAS_NODE_ROLE");

    address[] public dasNodeAddresses;
    mapping(address => bool) public dasNodeExists;

    constructor(){
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /**
     * @dev Thrown when the signer is not sequencer address.
     */
    error InvalidAddress(address addr);

    /**
     * @dev Thrown when the merkle proof is wrong.
     */
    error DASNodeExist(address);

    function addDASNodeAddress(address _dasNodeAddress) public onlyRole(DEFAULT_ADMIN_ROLE) {
        if (_dasNodeAddress == address(0)) {
            revert InvalidAddress();
        }

        if (dasNodeExists[_dasNodeAddress]) {
            revert DASNodeExist(_dasNodeAddress);
        }

        claim();

        dasNodeAddresses.push(_dasNodeAddress);
        dasNodeExists[_dasNodeAddress] = true;
        _grantRole(DAS_NODE_ROLE, _dasNodeAddress);
    }

    function claim() public {
        for (uint i = 0; i < dasNodeAddresses.length; i++) {
            address payable addr = payable(dasNodeAddresses[i]);
            addr.transfer(address(this).balance / dasNodeAddresses.length);
        }
    }

    // Fallback function to receive ETH
    receive() external payable {}
}
