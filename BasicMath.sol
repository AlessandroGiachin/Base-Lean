{\rtf1\ansi\ansicpg1252\cocoartf2639
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx566\tx1133\tx1700\tx2267\tx2834\tx3401\tx3968\tx4535\tx5102\tx5669\tx6236\tx6803\pardirnatural\partightenfactor0

\f0\fs24 \cf0 // SPDX-License-Identifier: MIT\
pragma solidity ^0.8.0;\
\
contract BasicMath \{\
    // Funzione Adder\
    function adder(uint256 _a, uint256 _b) public pure returns (uint256 sum, bool error) \{\
        unchecked \{\
            sum = _a + _b;\
            if (sum < _a) \{ // Questo controllo verifica l'overflow\
                return (0, true);\
            \} else \{\
                return (sum, false);\
            \}\
        \}\
    \}\
\
    // Funzione Subtractor\
    function subtractor(uint256 _a, uint256 _b) public pure returns (uint256 difference, bool error) \{\
        if (_a < _b) \{ // Questo controllo verifica l'underflow\
            return (0, true);\
        \} else \{\
            difference = _a - _b;\
            return (difference, false);\
        \}\
    \}\
\}}