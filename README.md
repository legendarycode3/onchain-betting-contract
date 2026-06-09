# Onchain Betting Smart Contract

## 📌 Features
* ****Fixed Bet Amount Enforcement:**** Each player must stake a predefined fixed amount (`i_betAmount`).
* ****Two-Player Fixed Betting System:****
* ****Arbiter-Based Resolution:**** A trusted third party (i_arbiter) is responsible for: "Choosing the winner". Triggering payout via `resolveBetAndPayout()`. This makes it a centralized arbitration model inside a smart contract framework.
* ****Two-Player Fixed Betting System:**** The contract is designed for exactly two participants (`i_player1` and `i_player2`). Only these addresses are allowed to interact as bettors, ensuring a closed and controlled betting environment.
* ****Secure Staking Mechanism:**** Only participants can stake (`onlyParticipants`). Must send exact bet amount, prevents double staking. Requires exact bet amount

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
