// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// Importa l'implementazione standard ERC20 e EnumerableSet di OpenZeppelin
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

/// @notice Errore lanciato se un indirizzo ha già effettuato la chiamata a claim.
error TokensClaimed();
/// @notice Errore lanciato se si tenta di claimare token ma la fornitura è esaurita.
error AllTokensClaimed();
/// @notice Errore lanciato se l'indirizzo non detiene token.
error NoTokensHeld();
/// @notice Errore lanciato se il quorum richiesto è maggiore del totale dei token attualmente distribuiti.
error QuorumTooHigh(uint quorum);
/// @notice Errore lanciato se l'indirizzo ha già votato su una determinata issue.
error AlreadyVoted();
/// @notice Errore lanciato se si tenta di votare su un'issue già chiusa.
error VotingClosed();

contract WeightedVoting is ERC20 {
    using EnumerableSet for EnumerableSet.AddressSet;

    // La fornitura massima è di 1.000.000 token.
    uint public constant maxSupply = 1_000_000;
    // Totale dei token claimati tramite la funzione claim (non coincide con l'ERC20 _totalSupply, che viene gestito da ERC20)
    uint public totalClaimed;

    // Mapping per controllare se un indirizzo ha già fatto claim.
    mapping(address => bool) public claimed;

    // L'enum per i tipi di voto.
    enum Vote {
        AGAINST,
        FOR,
        ABSTAIN
    }

    /**
     * @dev La struct Issue DEVE essere definita con i membri nell'ordine seguente:
     *  - EnumerableSet.AddressSet voters
     *  - string issueDesc
     *  - uint votesFor
     *  - uint votesAgainst
     *  - uint votesAbstain
     *  - uint totalVotes
     *  - uint quorum
     *  - bool passed
     *  - bool closed
     */
    struct Issue {
        EnumerableSet.AddressSet voters;
        string issueDesc;
        uint votesFor;
        uint votesAgainst;
        uint votesAbstain;
        uint totalVotes;
        uint quorum;
        bool passed;
        bool closed;
    }

    // L'array delle issue è reso private per evitare l'esposizione di tipi interni.
    Issue[] private issues;

    // Struct per restituire i dati di un'issue (non possiamo restituire direttamente un EnumerableSet)
    struct IssueView {
        address[] voters;
        string issueDesc;
        uint votesFor;
        uint votesAgainst;
        uint votesAbstain;
        uint totalVotes;
        uint quorum;
        bool passed;
        bool closed;
    }

    /// @notice Il costruttore inizializza l'ERC20 e "brucia" (cioè riserva) l'elemento zero dell'array issues.
    constructor() ERC20("WeightedVoting", "WV") {
        // Impostiamo i decimali a 0, in modo che le quantità siano gestite come interi.
        // "Bruciamo" l'elemento zero creando una issue dummy.
        issues.push();
    }

    /// @notice Override per avere 0 decimali.
    function decimals() public view virtual override returns (uint8) {
        return 0;
    }

    /// @notice Permette a un indirizzo che non ha ancora fatto claim di ottenere 100 token.
    /// Se l'indirizzo ha già fatto claim, revert con TokensClaimed.
    /// Se distribuire altri token supererebbe il maxSupply, revert con AllTokensClaimed.
    function claim() external {
        if (claimed[msg.sender]) revert TokensClaimed();
        if (totalClaimed + 100 > maxSupply) revert AllTokensClaimed();

        claimed[msg.sender] = true;
        totalClaimed += 100;
        _mint(msg.sender, 100);
    }

    /**
     * @notice Permette ai detentori di token di creare una nuova issue.
     * @param _issueDesc La descrizione dell'issue.
     * @param _quorum Il numero di voti necessari per chiudere l'issue.
     * @return L'indice (ID) della nuova issue.
     *
     * Revert se:
     * - Il chiamante non possiede token (NoTokensHeld).
     * - Il quorum richiesto è maggiore del totale di token attualmente distribuiti (QuorumTooHigh).
     *
     * NOTA: Il controllo che il chiamante possieda token DEVE essere fatto PRIMA del controllo sul quorum,
     * poiché i test unitari confrontano le encoded error names.
     */
    function createIssue(string calldata _issueDesc, uint _quorum) external returns (uint) {
        if (balanceOf(msg.sender) == 0) revert NoTokensHeld();
        if (_quorum > totalSupply()) revert QuorumTooHigh(_quorum);

        issues.push();
        uint index = issues.length - 1;
        Issue storage issue = issues[index];
        issue.issueDesc = _issueDesc;
        issue.quorum = _quorum;
        // Gli altri campi (voti e flag) sono inizializzati a 0/false per default.
        return index;
    }

    /**
     * @notice Restituisce i dati dell'issue specificata da _id.
     * Poiché non possiamo restituire direttamente un EnumerableSet, convertiamo il set dei votanti in un array.
     */
    function getIssue(uint _id) external view returns (IssueView memory) {
        Issue storage issue = issues[_id];
        uint len = issue.voters.length();
        address[] memory votersArr = new address[](len);
        for (uint i = 0; i < len; i++) {
            votersArr[i] = issue.voters.at(i);
        }
        return IssueView({
            voters: votersArr,
            issueDesc: issue.issueDesc,
            votesFor: issue.votesFor,
            votesAgainst: issue.votesAgainst,
            votesAbstain: issue.votesAbstain,
            totalVotes: issue.totalVotes,
            quorum: issue.quorum,
            passed: issue.passed,
            closed: issue.closed
        });
    }

    /**
     * @notice Permette ai detentori di token di votare su una determinata issue.
     * Il voto viene espresso "in peso": il saldo intero del votante viene aggiunto al conteggio.
     * Se il votante ha già espresso voto per l'issue, revert con AlreadyVoted.
     * Se l'issue è già chiusa, revert con VotingClosed.
     * Se il votante non possiede token, revert con NoTokensHeld.
     *
     * Se, aggiungendo il voto, il totale dei voti raggiunge o supera il quorum, l'issue viene chiusa.
     * Se i voti "FOR" sono maggiori di quelli "AGAINST", l'issue viene marcata come superata.
     *
     * @param _issueId L'indice dell'issue su cui votare.
     * @param _vote Il tipo di voto espresso (AGAINST, FOR o ABSTAIN).
     */
    function vote(uint _issueId, Vote _vote) external {
        Issue storage issue = issues[_issueId];
        if (issue.closed) revert VotingClosed();
        if (issue.voters.contains(msg.sender)) revert AlreadyVoted();

        uint voterBalance = balanceOf(msg.sender);
        if (voterBalance == 0) revert NoTokensHeld();

        // Registra il voto: aggiunge il votante al set.
        issue.voters.add(msg.sender);

        // Aggiunge il voto al conteggio appropriato.
        if (_vote == Vote.FOR) {
            issue.votesFor += voterBalance;
        } else if (_vote == Vote.AGAINST) {
            issue.votesAgainst += voterBalance;
        } else if (_vote == Vote.ABSTAIN) {
            issue.votesAbstain += voterBalance;
        }
        issue.totalVotes += voterBalance;

        // Se il totale dei voti raggiunge o supera il quorum, chiudiamo l'issue.
        if (issue.totalVotes >= issue.quorum) {
            issue.closed = true;
            if (issue.votesFor > issue.votesAgainst) {
                issue.passed = true;
            }
        }
    }
}
