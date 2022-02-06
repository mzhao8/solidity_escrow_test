# Escrow contract

1. Initialize Escrow contract
* in EscrowNFT run the view function "contractAddress", then copy the output. This is the initialized contract address for EscrowNFT
* in Escrow, find "initialize" function. paste contents of clipboard into value for _escrowNftAddress and run. This initializes the Escrow contract.
* now, Escrow contract linked to EscrowNFT contract

2. Transfer ownership (set ownership to Escrow) so we can call mint()
* in Escrow, run the view function contractAddress
* in EscrowNFT, find transferOwnership function. paste the output of contractAddress here for newOwner (which is the Escrow contract)
* run transferOwnership function

3. Escrow Eth
* in Escrow, find escrowEth function
* specify your wallet address, a short duration, and a small amount of Ether
* run escrowEth function and approve the metamask popup





# Replit Solidity Template notes
Welcome to the world of Ethereum and web3! This is a beta template for Solidity development on Replit. Solidity is the language used to create Smart Contracts, which are programs that run on the Ethereum Blockchain.

Features include:
- Hot reloading
- Solidity error checking
- Deploying multiple contracts
- UI for testing out contracts
- Replit testnet + faucet

## Getting started
**Just press the `Run ▶️` button!**

- You should only need to do this once (and might take like 15s). This will install all relevant packages, start up the contract deployment UI, and compile your `contract.sol` file.

- `contract.sol` will automatically recompile whenever you edit it, and all your contracts inside of this file will be available to deploy from the UI.

- Pressing `cmd-s` or `ctrl-s` (windows) will reload the UI.

We have preinstalled packages from `@openzeppelin/contracts`. To install other solidity packages that are distributed on npm, make sure you install them using the Package Installer 📦 in the sidebar

## Examples

We included a few example contracts in the `examples` folder. These will not be automatically deployed or accessible in the UI, but you can copy / paste them into your main `contract.sol` file or import them. They're there for your reference!

## Future work

We're working on some other features for making development here a lot easier, which are included, but not limited to:

- LSP support for solidity
- Integration with hardhat for "local" (in-repl) testing
- An actual solidity REPL for quickly prototyping / testing functions or lines.

## Feedback

Please leave any comments on this repl's [spotlight page here](https://replit.com/@replit/Solidity-starter-beta?v=1).

The UI is subject to change (and still needs some real responsive work), so we'd appreciate any feedback there. 

We're also trying to improve the overall dev experience, especially for beginners, so any feedback there is appreciated. 
