# Raffle Smart Contract

## About

This smart contract implements a decentralized raffle system on the Stacks blockchain. It allows for the creation and management of raffles, ticket purchases, winner selection, and prize distribution.

## Features

•⁠  ⁠Raffle initialization with customizable parameters
•⁠  ⁠Ticket purchasing with limits
•⁠  ⁠Random winner selection
•⁠  ⁠Prize claiming
•⁠  ⁠Fee collection for the contract owner
•⁠  ⁠Raffle cancellation and refund functionality

## Contract Details

### Constants

•⁠  ⁠⁠ CONTRACT-OWNER ⁠: The owner of the contract (set to the contract deployer)
•⁠  ⁠Error codes for various scenarios (e.g., unauthorized access, insufficient balance)

### Data Variables

•⁠  ⁠⁠ raffle-state ⁠: Boolean indicating if a raffle is active
•⁠  ⁠⁠ ticket-cost ⁠: Cost of a single ticket (in microSTX)
•⁠  ⁠⁠ raffle-end-block ⁠: Block height at which the raffle ends
•⁠  ⁠⁠ winning-participant ⁠: The address of the winning participant
•⁠  ⁠⁠ prize-claim-status ⁠: Boolean indicating if the prize has been claimed
•⁠  ⁠⁠ minimum-participants ⁠: Minimum number of participants required for a valid raffle
•⁠  ⁠⁠ max-tickets-per-participant ⁠: Maximum number of tickets a single participant can purchase
•⁠  ⁠⁠ raffle-fee-rate ⁠: Percentage of the total pool taken as a fee (e.g., 5%)

### Maps

•⁠  ⁠⁠ participant-tickets ⁠: Tracks the number of tickets purchased by each participant
•⁠  ⁠⁠ participant-registry ⁠: Maps participant indices to their addresses
•⁠  ⁠⁠ participant-indices ⁠: Maps participant addresses to their indices

### Main Functions

1.⁠ ⁠⁠ initialize-raffle ⁠: Starts a new raffle with specified parameters
2.⁠ ⁠⁠ purchase-tickets ⁠: Allows participants to buy raffle tickets
3.⁠ ⁠⁠ conclude-raffle ⁠: Ends the raffle and selects a winner
4.⁠ ⁠⁠ claim-raffle-prize ⁠: Allows the winner to claim their prize
5.⁠ ⁠⁠ withdraw-raffle-fees ⁠: Enables the contract owner to withdraw collected fees
6.⁠ ⁠⁠ cancel-active-raffle ⁠: Cancels an active raffle if minimum participants aren't met
7.⁠ ⁠⁠ refund-participant-tickets ⁠: Refunds tickets if a raffle is cancelled

### Read-Only Functions

•⁠  ⁠⁠ get-ticket-price ⁠: Returns the current ticket price
•⁠  ⁠⁠ get-raffle-info ⁠: Provides information about the current raffle state
•⁠  ⁠⁠ get-participant-tickets ⁠: Returns the number of tickets owned by a participant
•⁠  ⁠⁠ get-winning-participant ⁠: Returns the address of the winning participant
•⁠  ⁠⁠ get-prize-info ⁠: Provides information about the prize status and total pool

## Usage

1.⁠ ⁠Deploy the contract to the Stacks blockchain.
2.⁠ ⁠The contract owner initializes a raffle using ⁠ initialize-raffle ⁠.
3.⁠ ⁠Participants purchase tickets using ⁠ purchase-tickets ⁠.
4.⁠ ⁠Once the raffle end block is reached, anyone can call ⁠ conclude-raffle ⁠ to select a winner.
5.⁠ ⁠The winner can claim their prize using ⁠ claim-raffle-prize ⁠.
6.⁠ ⁠The contract owner can withdraw fees using ⁠ withdraw-raffle-fees ⁠.

## Security Considerations

•⁠  ⁠The contract uses block height for randomness, which isn't cryptographically secure. In a production environment, consider using a more robust randomness source.
•⁠  ⁠There's no mechanism to update the contract owner. Consider implementing an ownership transfer function if needed.
•⁠  ⁠Ensure proper testing and auditing before deploying to mainnet.

## Development and Testing

To interact with and test this contract:

1.⁠ ⁠Use the [Clarinet](https://github.com/hirosystems/clarinet) development tool for local testing.
2.⁠ ⁠Deploy to testnet for further testing before mainnet deployment.
3.⁠ ⁠Use [Stacks.js](https://github.com/hirosystems/stacks.js) or other Stacks libraries to interact with the deployed contract.