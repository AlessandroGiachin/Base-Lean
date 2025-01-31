// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BasicMath {
    function adder(uint _a, uint _b) public pure returns (uint sum, bool error) {
        unchecked {
            if (_a > type(uint).max - _b) { // Overflow check
                return (0, true);
            }
            sum = _a + _b;
        }
        return (sum, false);
    }

    function subtractor(uint _a, uint _b) public pure returns (uint difference, bool error) {
        if (_a < _b) { // Underflow check
            return (0, true);
        } else if (_a == _b) { // Edge case for equal values
            return (0, false);
        }
        return (_a - _b, false);
    }
}