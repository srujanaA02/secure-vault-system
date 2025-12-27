# Secure Vault System

An authorization-governed vault system for controlled asset withdrawals using smart contracts. This system implements a secure multi-contract architecture where fund custody and permission validation are separated to reduce risk and improve clarity.

## Overview

The Secure Vault System is composed of two smart contracts:

1. **SecureVault.sol** - Holds and manages vault funds
2. **AuthorizationManager.sol** - Validates withdrawal permissions

This separation of concerns ensures that:
- The vault never performs cryptographic verification itself
- Permissions are validated through a dedicated authorization manager
- Withdrawals only succeed with explicit authorization
- Each authorization can only be used once

## Project Structure

```
├── contracts/
│   ├── AuthorizationManager.sol
│   └── SecureVault.sol
├── scripts/
│   └── deploy.js
├── tests/
│   └── system.spec.js
├── docker/
│   ├── Dockerfile
│   └── entrypoint.sh
├── docker-compose.yml
├── hardhat.config.js
├── package.json
└── README.md
```

## Getting Started

### Installation

1. Clone the repository
```bash
git clone https://github.com/srujanaA02/secure-vault-system.git
cd secure-vault-system
```

2. Install dependencies
```bash
npm install
```

### Running with Docker

The easiest way to run the system is using Docker:

```bash
docker-compose up
```

This will:
1. Start a local Hardhat node
2. Compile the contracts
3. Deploy AuthorizationManager and SecureVault
4. Initialize the vault with the authorization manager
5. Output deployment information

## Smart Contract Details

### AuthorizationManager

Responsible for managing and validating withdrawal authorizations:

- **verifyAuthorization()** - Verifies and consumes an authorization
- **isAuthorizationConsumed()** - Checks if an authorization has been used

**Key Features:**
- Prevents authorization reuse
- Binds authorizations to specific vault, recipient, and amount
- Emits events for authorization consumption

### SecureVault

Holds funds and executes authorized withdrawals:

- **receive()** - Accepts deposits of native currency
- **withdraw()** - Executes withdrawals with authorization
- **initialize()** - Sets the authorization manager (protected from re-initialization)
- **getBalance()** - Returns current vault balance

**Key Features:**
- Updates state before transferring value (checks-effects-interactions pattern)
- Requires authorization from AuthorizationManager
- Tracks total balance
- Emits events for deposits and withdrawals

## Authorization Flow

1. **Off-chain Authorization Generation**
   - Authorization parameters are determined (vault, recipient, amount, authId)
   - Authorization is signed

2. **On-chain Withdrawal Request**
   - User calls `vault.withdraw(recipient, amount, authId, signature)`
   - Vault requests authorization verification
   - AuthorizationManager checks:
     - Authorization hasn't been used before
     - Authorization parameters are valid
   - If valid, authorization is marked as consumed

3. **Funds Transfer**
   - Vault updates internal balance
   - Funds are transferred to recipient
   - Event is emitted

## Security Considerations

### Authorization Design
- Authorizations are bound to specific vault, network, recipient, and amount
- Each authorization includes a unique identifier to prevent duplicates
- Authorization data is deterministically constructed
- One-time use enforced through tracking in AuthorizationManager

### State Management
- All critical state updates occur before value transfers
- No assumptions about call ordering or caller behavior
- Initialization logic is protected from re-execution

### Invariants
- Vault balance can never become negative
- Each successful withdrawal uses exactly one authorization
- Permissions cannot be reused for multiple withdrawals
- State transitions occur deterministically

## Testing

Run the test suite:

```bash
npm test
```

Tests cover:
- Deposit functionality
- Authorized withdrawals
- Authorization reuse prevention
- Event emission
- State consistency

## Deployment

### Local Deployment

```bash
npx hardhat run scripts/deploy.js --network localhost
```

This outputs deployment information including:
- AuthorizationManager contract address
- SecureVault contract address
- Network chain ID
- Deployment timestamp

## Assumptions and Limitations

1. **Signature Verification** - The current implementation accepts any signature. In production, implement proper ECDSA signature verification against a signer address.

2. **Authorization Format** - The authorization format is simplified. Production systems should implement more robust authorization encoding and validation.

3. **Network Binding** - Authorizations are bound to network chain ID to prevent replay attacks across different networks.

4. **Local Development** - This system is designed for local testing and development. Additional security audits and features would be needed for mainnet deployment.

## Architecture Highlights

- **Separation of Concerns** - Vault and authorization logic are separate
- **One-Time Authorization** - Each authorization can only be used once
- **Deterministic Behavior** - All operations are deterministic and reproducible
- **Event-Driven** - All critical operations emit events for observability
- **Initialization Protection** - Vault initialization is protected from re-execution

## License

MIT
