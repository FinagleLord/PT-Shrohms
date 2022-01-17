pragma solidity ^0.8.0;

interface IConsumerBase {
    function fulfillRandomness(bytes32 requestId, uint256 randomness) external virtual;
}

contract MockVRF {

    function requestRandomness(
        bytes32 _keyHash, 
        uint256 _fee
    ) internal returns (bytes32 requestId) {
        // get some bs randomness
        uint256 randomness = uint256(keccak256(abi.encodePacked(msg.sender, block.number)));
        // immediately fulfillRandomness for conveinence
        IConsumerBase(msg.sender).fulfillRandomness(bytes32("your mom"), randomness);
    }

}