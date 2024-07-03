// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract ZkBlob is AccessControl {
    bytes32 public constant ZKBLOB_ROLE = keccak256("ZKBLOB_ROLE");
    address public zkblobAddress;

    mapping(uint256 => bytes32) public roots;

    /**
     * @dev Thrown when the batch number is nonexistent
     */
    error WrongBatchNum(uint256 batchNum);

    /**
     * @dev Thrown when the batch number is repeated.
     */
    error RepeatedBatch(uint256 batchNum);

    /**
     * @dev Thrown when the signer is not zkblob address.
     */
    error WrongSignature(address signer);

    /**
     * @dev Thrown when the merkle proof is wrong.
     */
    error InvalidMerkleProof();

    /**
     * @dev Thrown when the zkblob address is not set
     */
    error ZkBlobAddressNotSet();

    /**
     * @dev Thrown when the batch count not match
     */
    error PostBatchCountNotMatch();


    constructor(address _zkblobAddress){
        zkblobAddress = _zkblobAddress;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);

        _grantRole(ZKBLOB_ROLE, _zkblobAddress);
    }

    function setZkBlobAddress(address _zkblobAddress) public onlyRole(DEFAULT_ADMIN_ROLE) {
        zkblobAddress = _zkblobAddress;
        // Revoke old zkblob
        _revokeRole(ZKBLOB_ROLE, zkblobAddress);
        // Grant new zkblob
        _grantRole(ZKBLOB_ROLE, _zkblobAddress);
    }

    function postBatchs(uint256[] memory batchNum, bytes32[] memory root, bytes memory signature) public onlyRole(ZKBLOB_ROLE) {
        if(batchNum.length != root.length) {
            revert PostBatchCountNotMatch();
        }

        for (uint256 i = 0; i < batchNum.length; i++) {
            if (roots[batchNum[i]] != bytes32(0)) {
                revert RepeatedBatch(batchNum[i]);
            }
        }

        bytes32 signedHash = keccak256(abi.encodePacked(batchNum, root));

        address signer = ECDSA.recover(signedHash, signature);
        if (signer != zkblobAddress) {
            revert WrongSignature(signer);
        }

        for (uint256 i = 0; i < batchNum.length; i++) {
            roots[batchNum[i]] = root[i];
        }
    }

    function verifyBlob(uint256 batchNum, bytes32 hash, bytes32[] calldata merkleProof) public view returns(bool) {
        bytes32 root = roots[batchNum];
        if (root == bytes32(0)) {
            return false;
        }

        return MerkleProof.verify(merkleProof, root, hash);
    }
}
