// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EmployeeStorage {
    // Ottimizzazione dello storage
    uint16 private shares; // 2 byte
    uint32 private salary; // 4 byte
    uint256 public idNumber; // 32 byte, deve stare in un proprio slot
    string public name; // Stringa, va in un altro slot di storage

    // Custom error
    error TooManyShares(uint256 totalShares);

    // Constructor
    constructor() {
        shares = 1000;
        salary = 50000;
        idNumber = 112358132134;
        name = "Pat";
    }

    // Function to view salary
    function viewSalary() public view returns (uint32) {
        return salary;
    }

    // Function to view shares
    function viewShares() public view returns (uint16) {
        return shares;
    }

    // Function to grant shares
    function grantShares(uint16 _newShares) public {
        uint256 newTotal = shares + _newShares;

        if (_newShares > 5000) {
            revert("Too many shares");
        }
        if (newTotal > 5000) {
            revert TooManyShares(newTotal);
        }

        shares += _newShares;
    }

    // Function to check storage packing
    function checkForPacking(uint _slot) public view returns (uint r) {
        assembly {
            r := sload(_slot)
        }
    }

    // Debug function to reset shares
    function debugResetShares() public {
        shares = 1000;
    }
}
