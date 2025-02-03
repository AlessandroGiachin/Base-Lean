// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FavoriteRecords {
    mapping(string => bool) public approvedRecords;
    mapping(address => mapping(string => bool)) private userFavorites;
    string[] private approvedList;

    error NotApproved(string albumName);

    event RecordAdded(address indexed user, string albumName);
    event FavoritesReset(address indexed user);

    constructor() {
        string[9] memory albums = [
            "Thriller", "Back in Black", "The Bodyguard", "The Dark Side of the Moon", 
            "Their Greatest Hits (1971-1975)", "Hotel California", "Come On Over", 
            "Rumours", "Saturday Night Fever"
        ];
        for (uint i = 0; i < albums.length; i++) {
            approvedRecords[albums[i]] = true;
            approvedList.push(albums[i]);
        }
    }

    function getApprovedRecords() public view returns (string[] memory) {
        return approvedList;
    }

    function addRecord(string calldata albumName) public {
        if (!approvedRecords[albumName]) {
            revert NotApproved(albumName);
        }
        userFavorites[msg.sender][albumName] = true;
        emit RecordAdded(msg.sender, albumName);
    }

    function getUserFavorites(address user) public view returns (string[] memory) {
        uint count = 0;
        for (uint i = 0; i < approvedList.length; i++) {
            if (userFavorites[user][approvedList[i]]) {
                count++;
            }
        }

        string[] memory favorites = new string[](count);
        uint index = 0;
        for (uint i = 0; i < approvedList.length; i++) {
            if (userFavorites[user][approvedList[i]]) {
                favorites[index] = approvedList[i];
                index++;
            }
        }
        return favorites;
    }

    function resetUserFavorites() public {
        for (uint i = 0; i < approvedList.length; i++) {
            delete userFavorites[msg.sender][approvedList[i]];
        }
        emit FavoritesReset(msg.sender);
    }
}
