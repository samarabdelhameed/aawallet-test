**Contact:** samarabdelhameed

# ERC-4337 Simple Account Wallet

A professional, production-ready implementation of an ERC-4337 Account Abstraction wallet using Foundry. This project provides a complete wallet solution with EntryPoint, AccountFactory, and SimpleAccount contracts, all fully ERC-4337-compliant and tested.

## 🚀 Features

- **Full ERC-4337 Compliance**: All contracts follow the official ERC-4337 spec, including signature and nonce validation, UserOperation struct, and event emission.
- **Professional EntryPoint**: Implements handleOps, simulateValidation, deposit/withdraw, and full UserOperation execution logic.
- **SimpleAccount**: Real signature validation using OpenZeppelin ECDSA, nonce management, and secure execution.
- **AccountFactory**: Deterministic account creation, compatible with ERC-4337 flows.
- **Modular Interfaces**: Includes IEntryPoint and ISimpleAccount interfaces for extensibility.
- **Comprehensive Test Suite**: All contracts are covered by realistic, professional tests using Foundry.

## 📋 Prerequisites

- [Foundry](https://getfoundry.sh/) (latest version)
- Node.js (v16 or higher)
- Git

## 🛠️ Installation

1. **Clone the repository**

   ```bash
   git clone <your-repo-url>
   cd smart-contract
   ```

2. **Install dependencies**

   ```bash
   forge install
   ```

3. **Set up environment variables**

   ```bash
   cp .env.example .env
   ```

   Fill in your environment variables:

   ```env
   PRIVATE_KEY=your_private_key_here
   ETHERSCAN_API_KEY=your_etherscan_api_key_here
   SEPOLIA_RPC_URL=your_sepolia_rpc_url_here
   ```

## 🏗️ Project Structure

```
smart-contract/
├── src/
│   ├── EntryPoint.sol          # ERC-4337 EntryPoint contract (full logic)
│   ├── AccountFactory.sol      # Account factory for creating wallets
│   ├── SimpleAccount.sol       # Simple account implementation (real signature/nonce validation)
│   ├── IEntryPoint.sol         # ERC-4337 interface
│   └── ISimpleAccount.sol      # Interface for account contracts
├── script/
│   ├── EntryPoint.s.sol        # EntryPoint deployment script
│   ├── AccountFactory.s.sol    # AccountFactory deployment script
│   └── SimpleAccount.s.sol     # SimpleAccount deployment script
├── test/
│   ├── EntryPoint.t.sol        # EntryPoint tests
│   ├── EntryPointProfessional.t.sol # Professional EntryPoint tests
│   ├── AccountFactory.t.sol    # AccountFactory tests
│   └── SimpleAccount.t.sol     # SimpleAccount tests (real signature/nonce)
└── foundry.toml               # Foundry configuration
```

## 🧪 Professional Test Suite

All contracts are covered by a comprehensive, realistic test suite using Foundry. Tests include:

- Signature and nonce validation
- UserOperation struct and hash logic
- Full handleOps execution
- Account creation and execution flows
- Failure scenarios and revert reasons

Run all tests:

```bash
forge test -vvv
```

## 🚀 Deployment

### Deploy to Sepolia Testnet

1. **Deploy EntryPoint**

   ```bash
   forge script script/EntryPoint.s.sol:EntryPointDeploy \
     --rpc-url $SEPOLIA_RPC_URL \
     --private-key $PRIVATE_KEY \
     --broadcast \
     --verify \
     -vvvv
   ```

2. **Deploy AccountFactory**

   ```bash
   forge script script/AccountFactory.s.sol:AccountFactoryDeploy \
     --rpc-url $SEPOLIA_RPC_URL \
     --private-key $PRIVATE_KEY \
     --broadcast \
     --verify \
     -vvvv
   ```

3. **Deploy SimpleAccount**
   ```bash
   forge script script/SimpleAccount.s.sol:SimpleAccountScript \
     --rpc-url $SEPOLIA_RPC_URL \
     --private-key $PRIVATE_KEY \
     --broadcast \
     --verify \
     -vvvv
   ```

## 📍 Deployment Results

### Sepolia Testnet Contracts

| Contract           | Address                                      | Status                 | Etherscan                                                                               |
| ------------------ | -------------------------------------------- | ---------------------- | --------------------------------------------------------------------------------------- |
| **EntryPoint**     | `0xef78742Ba63f2eC1533E7A3Dfe83120eb3EB99aa` | ✅ Deployed & Verified | [View](https://sepolia.etherscan.io/address/0xef78742Ba63f2eC1533E7A3Dfe83120eb3EB99aa) |
| **AccountFactory** | `0xA292D4505aD066378b8335f7C1479a0216D89F2e` | ✅ Deployed & Verified | [View](https://sepolia.etherscan.io/address/0xA292D4505aD066378b8335f7C1479a0216D89F2e) |
| **SimpleAccount**  | `0xb3946cdC44ed9111e8f69B9d597455810FFdc4e7` | ✅ Deployed & Verified | [View](https://sepolia.etherscan.io/address/0xb3946cdC44ed9111e8f69B9d597455810FFdc4e7) |

### Deployment Details

- **Network**: Sepolia Testnet
- **Deployer**: `0x14D7795A2566Cd16eaA1419A26ddB643CE523655`
- **Total Gas Used**: ~1.8M gas
- **Total Cost**: ~0.000018 ETH

### Transaction Hashes

- **EntryPoint**: `0x2e04b88b59c2a3c8eabdadcf59aa7ad227b9a2e1db70bf3e91c04441f02606ca`
- **AccountFactory**: `0x14613be7403f44a1356fd5b3278bfce34cb225a08681bb0c5f80a8e101c4e70d`
- **SimpleAccount**: `0xa449a9dd338b85a493968cf69ca7e51ca8ff801dfe4826fcf0370645aa926508`

## 🔧 Contract Architecture

### EntryPoint

The standard ERC-4337 EntryPoint contract that handles UserOperations and coordinates the execution of account abstraction transactions.

**Key Functions:**

- `handleOps()` - Process UserOperations
- `simulateValidation()` - Simulate operation validation
- `getNonce()` - Get account nonce

### AccountFactory

Factory contract for creating new SimpleAccount instances.

**Key Functions:**

- `createAccount()` - Create new account
- `getAddress()` - Get account address for given owner

### SimpleAccount

A simple ERC-4337 compliant account implementation.

**Key Functions:**

- `execute()` - Execute transactions
- `validateUserOp()` - Validate UserOperations
- `addDeposit()` - Add deposit to account

## 📖 Usage Examples

### Creating a New Account

```solidity
// Using AccountFactory
AccountFactory factory = AccountFactory(0xA292D4505aD066378b8335f7C1479a0216D89F2e);
address newAccount = factory.createAccount(owner, salt);
```

### Executing a Transaction

```solidity
// Using SimpleAccount
SimpleAccount account = SimpleAccount(accountAddress);
account.execute(target, value, data);
```

## 🔒 Security & Best Practices

- **OpenZeppelin ECDSA** is used for signature recovery and validation.
- **ISimpleAccount** interface ensures compatibility for any custom account logic.
- **All critical logic is covered by tests**.
- **No placeholder code**: all logic is real and production-ready.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [ERC-4337 Specification](https://eips.ethereum.org/EIPS/eip-4337)
- [Foundry Framework](https://getfoundry.sh/)
- [OpenZeppelin Contracts](https://openzeppelin.com/contracts/)

## 📞 Support

For support and questions:

- Create an issue in this repository
- Check the [ERC-4337 documentation](https://docs.erc4337.io/)

---

**Note**: This is a testnet deployment. For mainnet deployment, ensure thorough testing and security audits.
