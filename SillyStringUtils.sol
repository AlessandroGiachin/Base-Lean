// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

library SillyStringUtils {
    struct Haiku {
        string line1;
        string line2;
        string line3;
    }

    // Funzione per aggiungere il "shruggie" alla fine di una stringa
    function shruggie(string memory _input) internal pure returns (string memory) {
        return string(abi.encodePacked(_input, unicode" 🤷"));
    }
}
