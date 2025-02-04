// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract ErrorTriageExercise {
    /**
     * @notice Calcola la differenza assoluta tra ogni coppia di numeri consecutivi.
     * Restituisce un array di uint contenente le differenze: |a-b|, |b-c|, |c-d|.
     */
    function diffWithNeighbor(
        uint _a,
        uint _b,
        uint _c,
        uint _d
    ) public pure returns (uint[] memory) {
        uint[] memory results = new uint[](3);
        
        results[0] = _a >= _b ? _a - _b : _b - _a;
        results[1] = _b >= _c ? _b - _c : _c - _b;
        results[2] = _c >= _d ? _c - _d : _d - _c;
        
        return results;
    }

    /**
     * @notice Applica un modificatore (che può essere negativo o positivo) al valore base.
     * Il valore base viene modificato e restituito come uint.
     * Se la somma risultasse negativa, la funzione fallirà.
     */
    function applyModifier(
        uint _base,
        int _modifier
    ) public pure returns (uint) {
        int newValue = int(_base) + _modifier;
        require(newValue >= 0, "Il risultato non puo' essere negativo");
        return uint(newValue);
    }

    // Array di utilità
    uint[] private arr;

    /**
     * @notice Rimuove l'ultimo elemento dell'array e lo restituisce.
     * Se l'array è vuoto, la funzione fallisce.
     */
    function popWithReturn() public returns (uint) {
        require(arr.length > 0, "Array vuoto");
        uint lastValue = arr[arr.length - 1];
        arr.pop();
        return lastValue;
    }

    // Funzioni di utilità già funzionanti

    /**
     * @notice Aggiunge un numero all'array.
     */
    function addToArr(uint _num) public {
        arr.push(_num);
    }

    /**
     * @notice Restituisce l'intero array.
     */
    function getArr() public view returns (uint[] memory) {
        return arr;
    }

    /**
     * @notice Resetta (svuota) l'array.
     */
    function resetArr() public {
        delete arr;
    }
}
