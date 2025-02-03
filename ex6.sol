// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GarageManager {

    struct Car {
        string make;
        string model;
        string color;
        uint numberOfDoors;
    }

    // Mapping to store cars for each address
    mapping(address => Car[]) public garage;

    // Custom error for invalid car index
    error BadCarIndex(uint index);

    // Function to add a car to the garage
    function addCar(string memory make, string memory model, string memory color, uint numberOfDoors) public {
        Car memory newCar = Car(make, model, color, numberOfDoors);
        garage[msg.sender].push(newCar);
    }

    // Function to get all cars for the calling user
    function getMyCars() public view returns (Car[] memory) {
        return garage[msg.sender];
    }

    // Function to get all cars for a given address
    function getUserCars(address user) public view returns (Car[] memory) {
        return garage[user];
    }

    // Function to update a car
    function updateCar(uint index, string memory make, string memory model, string memory color, uint numberOfDoors) public {
        if (index >= garage[msg.sender].length) {
            revert BadCarIndex(index);
        }

        Car storage carToUpdate = garage[msg.sender][index];
        carToUpdate.make = make;
        carToUpdate.model = model;
        carToUpdate.color = color;
        carToUpdate.numberOfDoors = numberOfDoors;
    }

    // Function to reset the garage (delete all cars for the sender)
    function resetMyGarage() public {
        delete garage[msg.sender];
    }
}
