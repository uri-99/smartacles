//SPDX-License-Identifier: This is my contract. There are many like it, but this one is mine.
pragma solidity ^0.8.26;

contract GoodOlRoulette {
    struct Bet {
        uint256 amount;
        uint8 chosenNumber;
    }

    mapping(bytes32 => Bet) public bets;

    uint256 public _blocksAhead = 7;

    event Bet(address indexed user, Bet bet);
    event Won(address indexed user, uint256 amount);
    event Lost(address indexed user, uint256 amount);

    // TODO: add functionality of paying to bet on:
    // Odd/Even
    // Red/Black
    // 1-18/19-36
    // 1st/2nd/3rd 12
    // 1-2-3 columns
    // Double numbers
    // Three numbers (row)
    // 4 numbers (square)
    // 6 numbers (double row)
    // 0/00

    function bet(uint8 _chosenNumber) external payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");
        require(
            _chosenNumber >= 0 && _chosenNumber <= 36,
            "Number must be between 0 and 36"
        );

        bets[keccak256(abi.encodePacked(msg.sender, block.number))] = Bet{
            amount: msg.value,
            chosenNumber: _chosenNumber
        };

        emit Bet(msg.sender, Bet, block.number);
    }

    function claim(uint256 blockNumber) external {
        require(
            block.number > blockNumber + _blocksAhead,
            "Block number has not been mined yet"
        );
        require(
            block.number <= blockNumber + _blocksAhead + 256,
            "Block number is too old"
        );

        Bet currentBet = bets[
            keccak256(abi.encodePacked(msg.sender, blockNumber))
        ];
        require(currentBet.amount > 0, "No bet found for this block number");

        uint8 winningNumber = uint64(blockhash(blockNumber + _blocksAhead)) % 37; //Based Randomizer

        if (currentBet.chosenNumber == winningNumber) {
            payable(msg.sender).transfer(currentBet.amount * 35);
            emit Won(msg.sender, currentBet.amount * 35);
        } else {
            emit Lost(msg.sender, currentBet.amount);
        }

    }
}
