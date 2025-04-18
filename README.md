# EtherVault

EtherVault is a secure and gas-efficient Ethereum smart contract built with Solidity, designed for handling ETH deposits and withdrawals. It features robust control mechanisms like cooldowns, pausability, and an emergency withdrawal mode to protect both users and contract owners.

---

## ✅ Features

- Users can securely deposit ETH above a dynamically set minimum (based on Chainlink oracle price).
- Withdrawals are only allowed after a cooldown period.
- Owner can pause the contract in emergencies.
- Emergency withdrawal mechanism for the owner after a set timeout.
- Fully tested with Forge (Foundry) for deposit, withdrawal, edge cases, and access control.
- Modular deployment and interaction scripts.
- Oracle integration with support for mainnet, Sepolia, and local mock price feeds.

---

![Foundry](https://img.shields.io/badge/Powered%20by-Foundry-%23E95420)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Tests](https://img.shields.io/badge/Tests-Passing-brightgreen)
![Coverage](https://img.shields.io/badge/Coverage-85.71%25-orange)

---

## 🧰 Tech Stack

- **Solidity** `^0.8.18`
- **Foundry** (Forge, Cast, Anvil)
- **Chainlink Oracles**
- **MockV3Aggregator** for local testing
- **Forge Cheatcodes** for user simulation and time manipulation

---

## 📂 Project Structure

```bash
├── src/ 
|     ├── EtherVault.sol
|     └── PriceConverter.sol
├── script/ 
|     ├── DeployEtherVault.s.sol
|     ├── HelperConfig.s.sol
|     └── Interact.s.sol
├── test/ 
|     ├── mocks
|     |     └── MockV3Aggregator.sol
|     └──TestEtherVault.t.sol
├── lib/
└── foundry.toml
```

---

## 🛠️ Installation

> Requires [Foundry](https://book.getfoundry.sh/getting-started/installation)

###  Install Foundry (if not already installed)
```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

---

## 📁 Clone the Repo

```bash
git clone https://github.com/your-username/ethervault.git
cd ethervault
forge install
```

---

## ⚙️ Compile the Contracts

```bash
forge build
```

---

## 🧪 Run Tests

```bash
forge test -vv
```

> `-vv` gives detailed logs for easier debugging.

---

## 🚀 Deploy to Local Network (Anvil)

Start Anvil (local blockchain):

```bash
anvil
```

Deploy the contract:

```bash
forge script script/DeployEtherVault.s.sol:DeployEtherVault --fork-url http://localhost:8545 --broadcast
```

---

## 🔗 Deploy to Sepolia (or other testnets)

Set up environment variables:

```bash
export SEPOLIA_RPC_URL=your_rpc_url
export PRIVATE_KEY=your_private_key
```

Then deploy:

```bash
forge script script/DeployEtherVault.s.sol:DeployEtherVault --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast
```

---

## 💬 Interact with the Contract

```bash
forge script script/Interact.s.sol:Interact --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast
```

Or for local testing:

```bash
forge script script/Interact.s.sol:Interact --fork-url http://localhost:8545 --broadcast
```

---

## 🧹 Clean Build Artifacts

```bash
forge clean
```

---

## 👨‍💻 Author

**Chirag Goyal**  
B.Tech, Chemical Engineering, IIT Roorkee  
Blockchain & Software Developer | Builder | Learner

---

## 📬 Feedback & Contributions

Feel free to raise an issue or contribute improvements to this project. All contributions are welcome.