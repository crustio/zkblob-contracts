// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract ZkBlob is AccessControl {
    bytes32 public constant SEQUENCER_ROLE = keccak256("SEQUENCER_ROLE");
    address public sequencerAddress;

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
     * @dev Thrown when the signer is not sequencer address.
     */
    error WrongSignature(address signer);

    /**
     * @dev Thrown when the merkle proof is wrong.
     */
    error InvalidMerkleProof();


    constructor(address _sequencerAddress){
        sequencerAddress = _sequencerAddress;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(SEQUENCER_ROLE, _sequencerAddress);
    }

    function setSequencerAddress(address _sequencerAddress) public onlyRole(DEFAULT_ADMIN_ROLE) {
        sequencerAddress = _sequencerAddress;
        // Revoke old sequencer
        _revokeRole(SEQUENCER_ROLE, sequencerAddress);
        // Grant new sequencer
        _grantRole(SEQUENCER_ROLE, _sequencerAddress);
    }

    function postBatch(uint256 batchNum, bytes32 root, bytes memory signature) public onlyRole(SEQUENCER_ROLE) {
        if (roots[batchNum] != bytes32(0)) {
            revert RepeatedBatch(batchNum);
        }

        bytes32 signedHash = keccak256(abi.encodePacked(batchNum, root));

        address signer = ECDSA.recover(signedHash, signature);
        if (signer != sequencerAddress) {
            revert WrongSignature(signer);
        }

        roots[batchNum] = root;
    }

    function verifyBlob(uint256 batchNum, bytes32 hash, bytes32[] calldata merkleProof) public view returns(bool) {
        bytes32 root = roots[batchNum];
        if (root == bytes32(0)) {
            return false;
        }

        return MerkleProof.verify(merkleProof, root, hash);
    }
}
