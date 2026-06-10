# Onchain Betting Smart Contract

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


## Why This Matters (Onchain Betting Smart Contract)
Onchain betting smart contracts matter because they fundamentally change how wagering systems are built, trusted, and operated. Instead of relying on a centralized bookmaker or platform, the rules and execution of

* ****Trustless Betting(No Intermediaries Needed):**** The onchain betting contracts removes the need for a bookmaker or centralized betting platform. Users don’t need to trust a company to hold or distribute funds. Instead, Smart contract holds funds (escrow), rules are enforced automatically, arbiter only decides outcome (not custody). This automatically reduces fraud risk and increases fairness.
* ****Onchain betting smart contracts matter:**** 



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
