# Onchain Betting Smart Contract

## 📌 Features
* ****Fixed Bet Amount Enforcement:**** Each player must stake a predefined fixed amount (`i_betAmount`).
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
* ****On-Chain Stake Tracking System:**** The contract tracks whether

## 🧠 Key Concepts Applied


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
