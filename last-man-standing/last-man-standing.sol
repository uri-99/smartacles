//SPDX-License-Identifier: This is my contract. There are many like it, but this one is mine.
pragma solidity ^0.8.26;

contract LastManStanding {
    address public lastDepositor;
    uint256 public priceToStand;

    uint256 public lastDepositBlock;
    uint256 public requiredBlocks;

    mapping(address => uint16) public champions;

    event IAmTheChampion(address champion);

    constructor(uint256 _requiredBlocks, uint256 _priceToStand) {
        requiredBlocks = _requiredBlocks;
        priceToStand = _priceToStand;
    }

    receive() external payable {
        require(msg.value > priceToStand, "Not enough Ether to Stand");
        lastDepositor = msg.sender;
        lastDepositBlock = block.number;
    }

    function withdraw(
        uint256 newRequiredBlocks,
        uint256 newPriceToStand
    ) external {
        require(
            msg.sender == lastDepositor,
            "You are not the Last Man Standing"
        );
        require(
            block.number >= lastDepositBlock + requiredBlocks,
            "Not enough blocks have passed to claim the Prize"
        );

        emit IAmTheChampion(msg.sender);
        champions[msg.sender]++;
        requiredBlocks = newRequiredBlocks;
        priceToStand = newPriceToStand;

        payable(msg.sender).transfer(address(this).balance);

        lastDepositor = address(0);
        lastDepositBlock = 0;
    }
}
