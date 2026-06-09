// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

/// @notice OpenZeppelin contracts for secure modifiers
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title  Betting Smart contract
 * @author LegendaryCode
 * @notice  Two parties stake(Bets) ETH on a result, winner takes. 
 */




contract OnchainBetting is ReentrancyGuard  {    
    
     /*///////////////////////////////////////////////////////////////
                                TYPE DECLARATIONS
    //////////////////////////////////////////////////////////////*/
    enum BetStatus {
        Pending, // The bet has been created but is not yet active/locked - 0

        Locked, // The event has started; bets are closed and can no longer be placed or modified - 1

        Resolved,  // Bet is resolved, winner determined - 2

        Claimed,   // The winning funds have been successfully withdrawn or distributed to the bettor - 3

        Canceled // The bet or event was voided (e.g., due to a canceled match), allowing users to claim a refund  - 4
    }



    /*///////////////////////////////////////////////////////////////
                                ERRORS
    //////////////////////////////////////////////////////////////*/
    /// @notice Custom error for invalid address input
    error Invalid__AddressProvided(); 

    /// @notice Custom error for when both players have the same address
    error Players__AddressesCannotBeSame(); 

    /// @notice Custom error for when the bet amount is zero or negative
    error Need__MoreThanZeroAmount(); 

    /// @notice Custom error for when the arbiter's address is thesame as either player's address
    error Arbiter__AddressesCannotBePlayer(); 

    /// @notice Custom error for when a non-participant tries to perform an action
    error NotAuthorized__OnlyParticipantsAllowed(); 

    /// @notice Custom error for when a non-arbiter tries to perform an action
    error Only__ArbiterAllowed(); 
    
    /// @notice Thrown when the submitted stake or bet amount does not match the required amount
    error Incorrect__StakeBetAmount(uint256 sent, uint256 required);

    /// @notice Reverts when an action is attempted on a bet that has not been placed yet.
    error InvalidBetStatus__BetNotPlacedYet(BetStatus betStatus);

    /// @notice Reverts when an operation requires all bets to be fully staked.
    error Bets__NotFullyStaked();

    /// @notice Reverts when attempting to resolve a bet that has already been resolved.
    error Bet__AlreadyResolved();

    /// @notice Reverts when the selected winner is not one of the valid participants.
    error Winner__NotParticipant(address attemptedWinner, address player1, address player2);

    /// @notice Reverts when a token or ETH transfer fails.
    error Transfer__Failed();

    /// @notice Reverts when there is no stake available to refund.
    error NoStake__ToRefund();

    /// @notice Reverts when a player attempts to stake more than once.
    error Player__AlreadyStaked();
    


    /*//////////////////////////////////////////////////////////////
                              STATE VARIABLES 
    //////////////////////////////////////////////////////////////*/
    ///@notice Address of the first participant
    address public immutable  i_player1; 

    /// @notice Address of the second participant
    address public immutable  i_player2; 

    /// @notice Trusted identity authorized to report the result
    address public immutable  i_arbiter; 
    
    /// @notice The exact amount of ETH required to enter the bet
    uint256 public immutable  i_betAmount; 

    /// @notice Tracks the lifecycle of the bet (e.g Pending, Locked, Resolved, Claimed)
    BetStatus public s_betStatus; 

    uint256 public s_totalPot = 0;

    /// @notice Tracks whether a player has already staked in the current bet.
    mapping(address => bool) public s_playerHasStaked;
    
    /// @notice Tracks whether an address has already claimed their reward or refund.
    mapping(address => bool) public s_hasClaimed;

    /// @notice Stores the balance of each participant.
    mapping(address => uint256) public s_balances;



    /*///////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Emitted when a player stakes funds in the betting contract.
    event Staked(address indexed player, uint256 amount);

    /// @notice Emitted when a bet is resolved and winnings are distributed.
    event BetResolved(address indexed winner, uint256 payout);

    /// @notice Emitted when a player is refunded.
    event Refunded(address indexed player, uint256 amount); 



    /*//////////////////////////////////////////////////////////////
                              MODIFIERS 
    //////////////////////////////////////////////////////////////*/
    
    // Modifier to restrict access to only the participants of the bet
    modifier onlyParticipants() {
        if(msg.sender != i_player1 &&  msg.sender != i_player2) {
            revert NotAuthorized__OnlyParticipantsAllowed();
        }
        _;
    }

    // Modifier to restrict access to only the arbiter(judge) who can resolve the bet
    modifier onlyArbiter() {
        if(msg.sender != i_arbiter) {
            revert Only__ArbiterAllowed();
        }
        _;
    }



    /*//////////////////////////////////////////////////////////////
                              FUNCTION 
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Initializes the betting contract with two players, a wager amount, and an arbiter.
     * @dev Reverts if any address is zero, if players are the same, if the bet amount is zero, 
     *      or if the arbiter is also a player. Sets the initial bet status to Pending.
     * @param _player1 The address of the first participant.
     * @param _player2 The address of the second participant.
     * @param _betAmount The required wager amount in wei.
     * @param _arbiter The address of the neutral third party to resolve disputes.
    */
    constructor(address _player1, address _player2, uint256 _betAmount, address _arbiter) payable {
        
        if (_player1 == address(0) || _player2 == address(0) || _arbiter == address(0)) {
            revert Invalid__AddressProvided();
        }

        if (_player1 == _player2) {
            revert Players__AddressesCannotBeSame();
        }

        if(_betAmount == 0) {
            revert Need__MoreThanZeroAmount();
        } 

        if(_player1 == _arbiter || _player2 == _arbiter) {
            revert Arbiter__AddressesCannotBePlayer();
        }

        i_player1 = _player1;
        i_player2 = _player2;
        i_betAmount = _betAmount;
        i_arbiter = _arbiter;
        s_betStatus = BetStatus.Pending;
        
    }


    /// @notice Required for the contract to receive ETH back from failed calls. (Allows the contract to receive ETH directly). 
    receive() external payable {}



    /**
     * @notice Allows either participant to stake the required bet amount into the contract.
     * @dev Each player can only stake once. When both players have staked successfully,
     *      the bet status transitions from Pending to Locked, preventing further staking and
     *      signaling that the arbiter can resolve the outcome.
     * 
     * @custom:reverts InvalidBetStatus__BetNotPlacedYet if betting is not in Pending or Locked state.
     * @custom:reverts Incorrect__StakeBetAmount if sent value does not match required bet amount
     * @custom:reverts Player__AlreadyStaked if the caller has already staked
     * @custom:security nonReentrant prevents reentrancy during ETH transfer context changes (future-proofing)
     */
    function stakeBetToken() external payable  onlyParticipants nonReentrant {

        if (s_betStatus != BetStatus.Pending && s_betStatus != BetStatus.Locked) {
            revert InvalidBetStatus__BetNotPlacedYet(s_betStatus);
        }

        if (msg.value != i_betAmount){
            revert Incorrect__StakeBetAmount(msg.value, i_betAmount);
        }

        if (s_playerHasStaked[msg.sender]) {
            revert Player__AlreadyStaked(); // Prevents double staking
        }

        s_playerHasStaked[msg.sender] = true;
        s_totalPot += msg.value;
        
        emit Staked(msg.sender, msg.value); 

          // Lock stakes once both parties have deposited (locks the pot for the arbiter to resolve)
        if(s_playerHasStaked[i_player1] && s_playerHasStaked[i_player2]){
            s_betStatus = BetStatus.Locked;
        }
    } 


    /**
     * @notice Arbiter Resolves the bet by selecting a winner and transferring the full pot to winner.
     * @dev Can only be called by the arbiter once both players have staked and the bet is Locked.
     * 
     * @param winner The address of the winning participant who will receive the payout
     */
    function resolveBetAndPayout(address payable winner) external onlyArbiter nonReentrant {
               
        if (s_betStatus != BetStatus.Locked) {
            revert Bets__NotFullyStaked();
        }

        if (winner != i_player1 && winner != i_player2) {
            revert Winner__NotParticipant(winner, i_player1, i_player2);
        }

        s_betStatus = BetStatus.Resolved;

        uint256 payout = s_totalPot;
        s_totalPot = 0; // Prevent reentrancy by clearing state before the call

        // Transfer total pot to the winner
        (bool success, ) = winner.call{value: payout}("");
  
        if(!success){
            revert Transfer__Failed();
        }
        
        emit BetResolved(winner, payout);

        s_betStatus = BetStatus.Claimed;
    }


   
    /***
     * @notice Allows a participant to refund their bet under valid conditions.
     * @dev Can only be called by registered participants when the bet is neither resolved nor locked.
     *      Ensures a player has staked before allowing refund, prevents double refunds,
     *      updates contract state, and securely transfers the staked amount back to the caller.
     *      Sets bet status to `Canceled` after execution.
     */
    function refund() external onlyParticipants nonReentrant  {
        if(s_betStatus == BetStatus.Resolved || s_betStatus == BetStatus.Locked){
            revert Bet__AlreadyResolved();
        }
        
        if (!s_playerHasStaked[msg.sender]) {
            revert NoStake__ToRefund();
        }
        
        // Prevent multiple refunds
        s_playerHasStaked[msg.sender] = false;
        
        uint256 amountToRefund = i_betAmount;
        s_totalPot -= amountToRefund;

        (bool success, ) = payable(msg.sender).call{value: amountToRefund}("");
        
        if(!success){
            revert Transfer__Failed();
        }

        emit Refunded(msg.sender, amountToRefund);
        
        s_betStatus = BetStatus.Canceled;
    }


    /**
     *  @notice Returns the internal balance of a given player.
     * @dev Reads from the contract’s balance mapping without modifying state.
     * 
     * 
     * @param _player The address whose balance is being queried.
     */
    function checkBalance(address _player) public view returns(uint256) {
        return s_balances[_player]; 
    }

}































































