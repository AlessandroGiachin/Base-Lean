// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ArraysExercise {
    uint[] public numbers = [1,2,3,4,5,6,7,8,9,10];
    address[] public senders;
    uint[] public timestamps;

    // Returns the entire numbers array
    function getNumbers() public view returns (uint[] memory) {
        return numbers;
    }

    // Resets the numbers array to its initial values (1-10) without using push()
    function resetNumbers() public {
        delete numbers;
        numbers = [1,2,3,4,5,6,7,8,9,10];
    }

    // Appends an array to numbers
    function appendToNumbers(uint[] calldata _toAppend) public {
        uint length = _toAppend.length;
        for (uint i = 0; i < length; i++) {
            numbers.push(_toAppend[i]);
        }
    }

    // Saves the caller's address and timestamp
    function saveTimestamp(uint _unixTimestamp) public {
        senders.push(msg.sender);
        timestamps.push(_unixTimestamp);
    }

    // Returns timestamps and corresponding senders after January 1, 2000 (Unix: 946702800)
    function afterY2K() public view returns (uint[] memory, address[] memory) {
        uint count = 0;
        for (uint i = 0; i < timestamps.length; i++) {
            if (timestamps[i] > 946702800) {
                count++;
            }
        }

        uint[] memory filteredTimestamps = new uint[](count);
        address[] memory filteredSenders = new address[](count);
        uint index = 0;
        for (uint i = 0; i < timestamps.length; i++) {
            if (timestamps[i] > 946702800) {
                filteredTimestamps[index] = timestamps[i];
                filteredSenders[index] = senders[i];
                index++;
            }
        }
        return (filteredTimestamps, filteredSenders);
    }

    // Resets senders array
    function resetSenders() public {
        delete senders;
    }

    // Resets timestamps array
    function resetTimestamps() public {
        delete timestamps;
    }
}
