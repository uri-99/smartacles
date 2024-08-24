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

        // Based Randomizer:
        // blockhash(blockNumber) is pseudorandom
        // => its first 9 bytes are also pseudorandom
        // And: 9 bytes are exactly representable as uint72
        // => uint72(blockhash) is pseudorandom
        // And:
        // min(uint72) % 38 = 0
        // max(uint72) % 38 = 37
        // => uint72(blockhash) % 38 has equal distribution between 0 and 37
        // => uint72(blockhash) % 38 is a pseudorandom number between 0 and 37
        // ... Roulette Bets are from 0 to 36, representing 37 as 00
        // We have a pseudorandom number generator that picks a number from an American Roulette Wheel
        //
        uint8 winningNumber = uint72(blockhash(blockNumber + _blocksAhead)) % 38;

        if (currentBet.chosenNumber == winningNumber) {
            payable(msg.sender).transfer(currentBet.amount * 35);
            emit Won(msg.sender, currentBet.amount * 35);
        } else {
            emit Lost(msg.sender, currentBet.amount);
        }

    }
}
