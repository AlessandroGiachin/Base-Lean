// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// Importiamo la libreria SillyStringUtils
import "./SillyStringUtils.sol";

contract ImportsExercise {
    // Dichiarazione della variabile pubblica 'haiku' di tipo 'Haiku'
    SillyStringUtils.Haiku public haiku;

    // Funzione per salvare il haiku
    function saveHaiku(string memory _line1, string memory _line2, string memory _line3) public {
        haiku.line1 = _line1;
        haiku.line2 = _line2;
        haiku.line3 = _line3;
    }

    // Funzione per ottenere il haiku completo come tipo Haiku
    function getHaiku() public view returns (SillyStringUtils.Haiku memory) {
        return haiku;
    }

    // Funzione che aggiunge 🤷 alla fine della terza riga del haiku senza modificarla
    function shruggieHaiku() public view returns (SillyStringUtils.Haiku memory) {
        // Creiamo una copia del haiku originale e aggiungiamo 🤷 alla terza riga
        SillyStringUtils.Haiku memory modifiedHaiku = haiku;
        modifiedHaiku.line3 = SillyStringUtils.shruggie(modifiedHaiku.line3);
        return modifiedHaiku;
    }
}
