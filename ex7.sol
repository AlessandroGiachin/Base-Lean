// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Contratto astratto Employee
abstract contract Employee {
    uint public idNumber;
    uint public managerId;

    constructor(uint _idNumber, uint _managerId) {
        idNumber = _idNumber;
        managerId = _managerId;
    }

    // Funzione virtuale da implementare nei contratti derivati
    function getAnnualCost() public view virtual returns (uint);
}

// Contratto Salaried che eredita da Employee
contract Salaried is Employee {
    uint public annualSalary;

    // Costruttore per inizializzare Employee e variabili di Salaried
    constructor(uint _idNumber, uint _managerId, uint _annualSalary) 
        Employee(_idNumber, _managerId) {
        annualSalary = _annualSalary;
    }

    // Override della funzione getAnnualCost
    function getAnnualCost() public view override returns (uint) {
        return annualSalary;
    }
}

// Contratto Hourly che eredita da Employee
contract Hourly is Employee {
    uint public hourlyRate;

    // Costruttore per inizializzare Employee e variabili di Hourly
    constructor(uint _idNumber, uint _managerId, uint _hourlyRate) 
        Employee(_idNumber, _managerId) {
        hourlyRate = _hourlyRate;
    }

    // Override della funzione getAnnualCost
    function getAnnualCost() public view override returns (uint) {
        return hourlyRate * 2080;  // 2080 ore all'anno
    }
}

// Contratto Manager
contract Manager {
    uint[] public employeeIds;

    // Aggiungi un id di un dipendente ai report
    function addReport(uint _idNumber) public {
        employeeIds.push(_idNumber);
    }

    // Resetta i report (svuota l'array)
    function resetReports() public {
        delete employeeIds;
    }
}

// Contratto Salesperson che eredita da Hourly
contract Salesperson is Hourly {
    constructor(uint _idNumber, uint _managerId, uint _hourlyRate) 
        Hourly(_idNumber, _managerId, _hourlyRate) {}
}

// Contratto EngineeringManager che eredita da Salaried e Manager
contract EngineeringManager is Salaried, Manager {
    constructor(uint _idNumber, uint _managerId, uint _annualSalary) 
        Salaried(_idNumber, _managerId, _annualSalary) {}
}

// Contratto InheritanceSubmission per salvare gli indirizzi dei contratti Salesperson e EngineeringManager
contract InheritanceSubmission {
    address public salesPerson;
    address public engineeringManager;

    constructor(address _salesPerson, address _engineeringManager) {
        salesPerson = _salesPerson;
        engineeringManager = _engineeringManager;
    }
}
