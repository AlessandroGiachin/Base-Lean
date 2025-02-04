// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/// @notice Errore lanciato se un indirizzo prova a effettuare una seconda chiamata a claim.
error TokensClaimed();

/// @notice Errore lanciato se tutti i token sono già stati distribuiti.
error AllTokensClaimed();

/// @notice Errore lanciato da safeTransfer se l'indirizzo destinatario non rispetta i requisiti.
error UnsafeTransfer(address to);

contract UnburnableToken {
    /// @notice Mapping che tiene traccia del numero di token posseduti da ciascun indirizzo.
    mapping(address => uint) public balances;
    
    /// @notice Totale dei token disponibili (100 milioni).
    uint public totalSupply;
    
    /// @notice Totale dei token già distribuiti tramite la funzione claim.
    uint public totalClaimed;
    
    /// @notice Mapping per verificare se un indirizzo ha già effettuato la richiesta di claim.
    mapping(address => bool) public hasClaimed;
    
    /// @notice Importo fisso che ogni indirizzo può richiedere una sola volta.
    uint public constant CLAIM_AMOUNT = 1000;

    /// @notice Il costruttore imposta il totalSupply a 100.000.000 token.
    constructor() {
        totalSupply = 100_000_000;
    }

    /**
     * @notice Permette ad un indirizzo che non ha ancora reclamato di ottenere 1000 token.
     * @dev Se l'indirizzo ha già effettuato il claim, la funzione revert con l'errore TokensClaimed.
     * Se la distribuzione di 1000 token farebbe superare il totalSupply, la funzione revert con AllTokensClaimed.
     */
    function claim() public {
        if (hasClaimed[msg.sender]) revert TokensClaimed();
        if (totalClaimed + CLAIM_AMOUNT > totalSupply) revert AllTokensClaimed();

        balances[msg.sender] += CLAIM_AMOUNT;
        totalClaimed += CLAIM_AMOUNT;
        hasClaimed[msg.sender] = true;
    }

    /**
     * @notice Permette di trasferire token in modo "sicuro" da chi invia al destinatario.
     * @dev Il trasferimento è consentito solo se:
     *      - L'indirizzo destinatario non è l'indirizzo zero.
     *      - L'indirizzo destinatario possiede un saldo di ETH (base Sepolia ETH) maggiore di zero.
     *      - Il mittente ha un saldo sufficiente di token.
     * Se una di queste condizioni non è soddisfatta, la funzione revert con l'errore UnsafeTransfer.
     * @param _to Indirizzo destinatario.
     * @param _amount Quantità di token da trasferire.
     */
    function safeTransfer(address _to, uint _amount) public {
        // Controllo: l'indirizzo destinatario non deve essere l'indirizzo zero
        // e deve avere un saldo di ETH maggiore di zero.
        if (_to == address(0) || _to.balance == 0) {
            revert UnsafeTransfer(_to);
        }
        // Controllo: il mittente deve avere almeno _amount token.
        require(balances[msg.sender] >= _amount, "Insufficient token balance");
        
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
    }
}
