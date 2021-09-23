# Oxychain smart contracts
This repository contains the smart contracts for Oxychain project. This set of contracts has been created to give life to the OXY and OXF tokens, and also to automate the trade operations of the marketplace.

## About the source code

The source code in this repo has been created from scratch but uses OpenZeppelin standard libraries for safety in basic operations and validations.

- [Getting Started](#getting-started)
  - [Requirements](#requirements)
  - [Deploy Token](#deploy-token)
- [Troubleshooting](#troubleshooting)

## Getting Started

### Requirements
You will need node.js (12.* or later) and npm installed to run it locally. We are using Hardhat to handle the project configuration and deployment. The configuration file can be found as `hardhat.config.js`.

1. Import the repository and `cd` into the new directory.
2. Run `npm install`.
3. Copy the file `.env.example` to `.env`, and:
   - Replace `DEPLOYER_KEY` with the private key of your account.
   - Replace `REMOTE_HTTP` with an INFURA or ALCHEMY url.
   - Replace `ETHERSCAN_KEY` with a API key from etherscan.
5. Make sure you have gas to run the transactions and deploy the contracts in your account.
6. Define the network where you want to deploy it in `hardhat.config.js`.

### Deploy Token
Run `npx hardhat run scripts/deploy-token.js --network YOUR_NETWORK`

## Troubleshooting

If you have any questions, send them along with a hi to hello@dandelionlabs.io.
