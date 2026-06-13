# Onchain Betting Smart Contract

## Project Overview
`Onchain Betting` is a decentralized peer-to-peer Ethereum wagering smart contract that enables two predefined participants to place equal ETH stakes on the outcome of an event. A trusted third-party arbiter is responsible for determining the winner and distributing the pooled funds. The contract emphasizes transparency, security, and trust-minimized bet settlement through on-chain execution.

### Core Features
* ****Two-Player Betting Model:**** Only two designated players can participate in a bet.
* ****Fixed Stake Amount:**** Both participants must deposit the exact predefined wager amount.
* ****Arbiter-Based Resolution:**** A neutral arbiter resolves the outcome and selects the winner.
* ****Winner-Takes-All Payout:**** The entire betting pool is transferred to the winning participant.
* ****Refund Mechanism:**** Players can recover their stake if the bet has not yet been locked or resolved.
* ****State Management:**** Uses a lifecycle-based status system (`Pending`, `Locked`, `Resolved`, `Claimed`, `Canceled`) to track bet progression.
* ****Security Protections:**** Integrates OpenZeppelin's `ReentrancyGuard` to prevent reentrancy attacks during ETH transfers.


## 📌 Features
* ****Fixed Bet Amount Enforcement:**** Each player must stake a predefined fixed amount (`i_betAmount`).
* ****Address Uniqueness:**** Reverts deployment if `player1` and `player2`  are set to the same address.
* ****Immutable State Variables:**** The players, arbiter, and bet amount are defined as `immutable`, permanently locking these critical parameters at deployment for trustlessness.
* ****Multi-Party Constructor:**** Requires explicit addresses for `player1`, `player2` , and the independent `arbiter` upon deployment.
* ****Two-Player Fixed Betting System:**** The contract is designed for exactly two participants (`i_player1` and `i_player2`). Only these addresses are allowed to interact as bettors, ensuring a closed and controlled betting environment.
* ****Arbiter-Based Resolution:**** A trusted third party (i_arbiter) is responsible for: "Choosing the winner". Triggering payout via `resolveBetAndPayout()`. This makes it a centralized arbitration model inside a smart contract framework.
* ****Two-Player Fixed Betting System:**** The contract is designed for exactly two participants (`i_player1` and `i_player2`). Only these addresses are allowed to interact as bettors, ensuring a closed and controlled betting environment.
* ****Secure Staking Mechanism:**** Only participants can stake (`onlyParticipants`). Must send exact bet amount, prevents double staking. Requires exact bet amount. Locks bet automatically when both players have staked.
* ****Reentrancy Protection:**** Inherits from OpenZeppelin's `ReentrancyGuard` to prevent malicious re-entry attacks. Protects sensitive functions: `stakeBetToken` , `resolveBetAndPayout`, `refund`. This reduces risk of reentrancy attacks during ETH transfers.
* ****Automated Payout:****  Upon resolution, the entire bet/wager pot is atomically transferred to the winning player.
* ****Participant-Restricted Interaction Layer:**** Only `i_player1` and `i_player2` can interact with staking and refund functions. This prevents unauthorized external addresses from injecting or extracting funds.
* ****Modifier-Based Security Enforcement:**** Access control is enforced via `onlyParticipants` and `onlyArbiter` modifiers, ensuring centralized and reusable permission logic.
* ****Custom Errors:****  Utilizes gas-efficient custom errors, instead of `require` strings to save deployment and execution costs.
* ****Anti-Overpayment Protection:**** Any ETH sent beyond or below the required amount is rejected, ensuring strict financial correctness.
* ****On-Chain Stake Tracking System:**** The contract tracks whether each participant has staked using boolean mapping, ensuring state clarity.
* ****Total Pot Accumulation:**** Automatically increments the `s_totalPot` state variable as each player stakes.
* ****Winner Validation:****  Ensures the arbiter only designates the payout to a valid participant (`player1` or `player2`).
* ****Resolved Status Enforcement:****  Ensures bets cannot be refunded once they reach the `Resolved` state.
* ****Player Address Tracking:**** Utilizes `s_playerHasStaked`  to map and verify if a participant has already deposited their required stake.
* ****Failure Handling:**** Reverts the transaction with a `Transfer__Failed` error if the Ether transfer to the winner fails.
* ****Auto-Lock Mechanism:**** Automatically changes the bet status from `Pending` to `Locked` the exact moment both `player1` and `player2`  have submitted their stakes.
* ****Double-Spend Protection:**** Tracks if a player has  already staked and reverts (`Player__AlreadyStaked`)  if they attempt to stake a second time.
* ****Zero-Address Validation:**** Prevents deployment if any participant or arbiter is assigned to the zero address (`0x000...000`).


## 🧠 Key Concepts Applied
* ****Modifiers(Access Control Layer):**** Used to prevents unauthorized function execution, which keeps keeps the code clean and reusable. Implemented to "restrict staking" to only `only players` authorised and "restrict resolution"  to only `only arbiter` authorized.
* ****Enums (State Machine Design Pattern):**** Prevents invalid actions at wrong stages. Enforces strict business logic flow. It is Used to implement a state machine
* ****Contract Inheritance (is ReentrancyGuard):**** The contract inherits from ReentrancyGuard, a security utility (commonly from OpenZeppelin). It helps Prevents reentrancy attacks. (where a malicious contract repeatedly calls into a function before state updates complete). It is used in `stakeBetToken()`, `resolveBetAndPayout()`, `refund()`.
* ****Constructor(Initialization Logic):**** Ensures contract integrate at deployment. It runs only once during deployment and Initializes immutable state.
* ****Custom Error(Gas Optimizer):**** A modern Solidity style that avoids require(string), for gas optization.
* ****Checks-Effects-Interactions Pattern (CEI):**** The pattern is implemented in other to minimizes reentrancy risk and ensures state is updated before external calls.
* ****Event Logging(On-chain Transparency Layer):**** Provides transparency for all actions. Events create an off-chain audit trail.
* ****Mappings(Key Data Storage Concept):**** It allows fast lookup of data associated with an address.
* ****Data Types:**** The contract uses several Solidity data types that define how data is stored and interpreted. 


## 📂 Project Structure (Files)
* ****`OnchainBetting.sol`****: Main smart contract file containing the complete On-Chain Betting system logic. </br>
  It includes: </br>
    * Participant (player) management.
    * Arbiter authorization and validation.
    * Fixed ETH Bet configuration.
    * Bet lifecycle management through multiple statuses (Pending, Locked, Resolved, Claimed, and Canceled).
    * ETH staking functionality for both participants.
    * Stake tracking and prevention of double staking.
    * Automatic bet locking when both players have deposited their stakes.
    * Winner validation and arbiter-controlled bet resolution.
    * Full pot payout to the winning participant.
    * Refund functionality for eligible participants before bet resolution.
    * Event emission for blockchain activity tracking.
    * Custom errors for gas-efficient error handling.
    * Security modifiers for participant and arbiter access control.
    * Reentrancy protection using OpenZeppelin's ReentrancyGuard.
    * State variables and helper/view functions for reading contract data. </br>
    
Purpose: </br>
Handles all on-chain betting operations including stake deposits, bet settlement, winner payouts, refunds, participant validation, access control, and security enforcement for a two-player ETH betting agreement.

* ****`OnchainBetting.t.sol`****: Test file written for validating the smart contract behavior using the Foundry testing framework. </br>
  It includes: </br>
    * Unit tests for all major contract functions.
    * Constructor initialization and configuration tests.
    * Address validation tests.
    * Player and arbiter setup verification.
    * Staking functionality tests.
    * Bet amount validation tests.
    * Participant authorization tests.
    * Double-staking prevention tests.
    * Event emission verification tests.
    * Bet status transition tests.
    * Bet locking verification after both players stake.
    * Arbiter authorization tests.
    * Bet resolution and payout tests.
    * Winner payout verification.
    * Refund functionality tests.
    * Balance and total pot accounting tests.
    * Revert and custom error validation.


## 🌐Technical Stack (Technologies Used)
* ****[Solidity](https://www.soliditylang.org/)**** - The programming language for writing the Smart contracts.
* ****[Remix IDE](https://remix.ethereum.org/)**** -  used it to write, and deploy the smart contract directly in the browser first.  A fastest way to get started, acting as a "no-setup" workshop for smart contract development. 
* ****[Foundry](https://www.getfoundry.sh/)**** -  Development framework  and testing suite.
* ****[Visual Studio Code](https://code.visualstudio.com/)**** - Install this IDE only if you are using foundry development kit rather than "Remix IDE" which is for quick prototying.
* ****[OpenZeppelin ReentrancyGuard](https://docs.openzeppelin.com/contracts/4.x/api/security#ReentrancyGuard/)**** - OpenZeppelin's ReentrancyGuard is a security utility in Solidity used to prevent reentrancy attacks in smart contracts. 

##  Getting Started
### Prerequisites
* Solidity Compiler, Version ^0.8.19 or higher.
* Remix IDE or Foundry Development Kit & Vscode

### Recommendation (For Beginners)
****NOTE (Use Remix IDE, for quick prototyping):****  You can literally just copy the main contract source code and paste it on Remix IDE and learn along side how how the code works while trying to build yours as you keep building.


## Usage
### Building the Project (Using Remix IDE):
1. Copy the core smart contract file code `OnchainBetting.sol`  to Remix IDE (a browser based IDE, for quick prototyping).
2. Create a new file for the project on your Remix IDE and paste , to learn and build along faster.
3. And then Compile the smart contract file you have created on Remix IDE.

### Building the Project (Using Foundry Development Kit )  - only if you are good using foundry kit
1. Clone the repository:
   ```shell
     git clone https://github.com/legendarycode3/onchain-betting-contract/
   ```
2. Navigate to the directory you created and cloned the file to:
   ```shell
      cd onchain-betting-contract
   ```
3. Compile the smart contract:
   `forge build`

### Testing the contract  (Using Foundry Development Kit )
Runing all tests:
   ```shell
          forge test 
   ```
</br> Runing specific test:
   ```shell
       forge test --mt testFunctionName
   ```


## 📋Contract Details
### Functions:
* ****`Constructor`****: Initializes a new betting agreement between two players and assigns an arbiter responsible for determining the outcome. Helps Validates that all addresses are non-zero, ensures both players are different addresses, ensures the betting amount is greater than zero, ensures the arbiter is not one of the players, and sets the bet status to `Pending`, as an initial state .
* ****`receive()`****: Prevents transactions from reverting when ETH is sent without calldata.
* ****`stakeBetToken()`****: Allows either participant to deposit the agreed wager or bet amount into the betting contract. It capability include: Restricting staking to only registered authorized participants, requires the exact bet amount to be sent, prevents double staking, prevents double staking, records the participant's stake, automatically locks the bet when both players have staked.
* ****`resolveBetAndPayout()`****: Allows the arbiter to determine the winner and transfer the entire betting pot to them. This function allows the designated arbiter to determine the outcome of the wager or bet and distribute the accumulated betting pool to the winning participant.
* ****`refund()`****: Allows a participant to withdraw their stake when the bet has not been successfully completed. The refund function allows a participant to recover their wager / bet under circumstances where the betting process cannot proceed to completion. This function is restricted to the registered participants and is intended to return deposited funds before a valid resolution occurs.
* ****`checkBalance()`****: Returns the internally tracked balance associated with a participant.


### Variables:
* ****`i_player1`****: Stores the address of the first betting participant. This address is supplied during contract deployment and cannot be modified afterward due to the `immutable` keyword.
* ****`i_player2`****: Stores the address of the second betting participant. Like `i_player1`, this value is permanently established during deployment and remains unchanged for the lifetime of the contract.
* ****`i_arbiter`****: Stores the address of the trusted third party responsible for determining the outcome of the wager or bet.
* ****`i_betAmount`****: Represents the exact amount of ETH that each participant must deposit to enter the wager or bet. This value is established during deployment and remains constant throughout the contract's lifetime. Every participant must stake precisely this amount when calling the staking function.
* ****`s_betStatus`****: Tracks the current stage of the betting lifecycle. This variable determines which actions are allowed at a given point in time and helps enforce the logical progression of the wager from creation to completion.
* ****`s_totalPot`****: Total amount of ETH currently held in the betting pool. The value increases whenever a participant stakes the required wager amount and decreases when funds are refunded or distributed. At the time of resolution, the full value of this variable is transferred to the winning participant.
* ****`s_playerHasStaked`****: Tracks whether a participant has already submitted their wager or bet. Each participant's address maps to a boolean value indicating whether they have completed the staking process. The mapping prevents duplicate deposits from the same player and allows the contract to determine when both participants have funded the wager.
* ****`s_hasClaimed`****: Intended to track whether a participant has already claimed funds associated with the wager.
* ****`s_balances`****: Intended to store the internal balance associated with each participant.



## Usage Guide (How to use - E.G When using RemixIDE) - Workflow
1. ****Deployment****
   * The contract is initialized with:
     * Player 1 address.
     * Player 2 address.
     * Fixed bet amount.
     * Arbiter address.
   * The bet starts in the Pending state.
2. ****Staking Phase****
   * Each player deposits the required ETH amount.
   * Once both players stake successfully, the contract moves to the `Locked` state.
   * No further staking or modifications are allowed.
3. ****Resolution Phase****
   * The arbiter selects the winning participant.
   * The full pot is transferred to the winner.
   * The bet status progresses through `Resolved` and finally `Claimed`.
4. ****Refund Phase****
   * If the bet has not been locked, participants may request a refund.
   * Upon successful refunding, the bet can transition to `Canceled`.


## Why This Matters (Onchain Betting Smart Contract)
Onchain betting smart contracts matter because they fundamentally change how wagering systems are built, trusted, and operated. Instead of relying on a centralized bookmaker or platform, the rules and execution of bets are handled by code deployed on a blockchain. Below are the key reasons this matters:

* ****Trustless Betting(No Intermediaries Needed):**** The onchain betting contracts removes the need for a bookmaker or centralized betting platform. Users don’t need to trust a company to hold or distribute funds. Instead, Smart contract holds funds (escrow), rules are enforced automatically, arbiter only decides outcome (not custody). This automatically reduces fraud risk and increases fairness.
* ****Transparency and Verifiability:**** Every transaction in an onchain betting system is recorded on a blockchain: Bets placed are visible, odds logic (if coded onchain) is inspectable, Payouts can be independently verified.
* ****Reduced fraud risk:**** Smart contracts remove common issues like manipulation of payouts, hidden rules, or refusal to pay winners.
* ****Automatic payouts:**** Winning conditions trigger instant settlement without human intervention or delays.
* ****Immutable rules:**** Once deployed, the contract logic can’t easily be changed, preventing unfair rule changes mid-game.
* ****Lower operational costs:**** No need for traditional intermediaries like betting companies or payment processors, which reduces fees.
* ****Programmable betting logic:**** You can create complex bets (parlays, conditional bets, prediction markets) that would be difficult in traditional systems.
* ****Real-time verification of outcomes:**** With oracles, external events (sports scores, prices, weather data) can be automatically verified and used.
* ****Provably Fair Randomness and Outcomes:**** When implemented  using secure oracle systems or verifiable randomness: Outcomes can be independently verified random events cannot be tampered with after the fact.
* ****Faster Settlement and Real-Time Markets:**** No waiting for manual review, outcomes resolve as soon as conditions are met. Because blockchain transactions settle automatically: Winnings can be paid instantly after event resolution, no banking delays or withdrawal queues, live betting can update in near real time.


## Security Consideration
* ****Access Control Enforcement:**** The contract restricts sensitive operations using role-based modifiers. Basically a Strict role-based access control via modifiers.
* ****Reentrancy Protection:**** The contract inherits from OpenZeppelin's `ReentrancyGuard` and applies the `nonReentrant` modifier to all functions that transfer ETH.
* ****Checks-Effects-Interactions Pattern:**** Before transferring ETH to a winner, the contract updates internal state. This reduces the risk of reentrancy exploits.
* ****Strict Participant Validation:**** The contract validates  critical addresses during deployment. This avoids configuration errors and role conflicts.
* ****Double-Staking Prevention:**** The contract prevents participants from staking multiple times. This protects the integrity of the betting pool and prevents accidental overfunding.
* ****Fixed Stake Amount Validation:**** Each participant must deposit exactly the predefined wager amount. This prevents stake manipulation and ensures fairness between bettors.
* ****Event-Based Transparency:**** This provides an auditable on-chain history and improves transparency for users and frontends.
* ****Custom Error:**** Custom errors for gas-efficient failure handling. 

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of (Some include):

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).

## Documentation

https://book.getfoundry.sh/

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```
