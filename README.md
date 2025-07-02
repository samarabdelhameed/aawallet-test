**Contact:** samarabdelhameed

# ERC-4337 Simple Account Wallet

A professional implementation of an ERC-4337 Account Abstraction wallet using Foundry. This project provides a complete wallet solution with EntryPoint, AccountFactory, and SimpleAccount contracts.

## 🚀 Features

- **Account Abstraction**: Full ERC-4337 compliance
- **Simple Account**: Easy-to-use wallet implementation
- **Account Factory**: Automated account creation
- **EntryPoint**: Standard ERC-4337 entry point
- **Gasless Transactions**: Support for sponsored transactions
- **Modular Design**: Clean, maintainable codebase

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
   OWNER=your_wallet_address_here
   ENTRYPOINT=0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789
   ```

   **Example .env file:**

   ```env
   PRIVATE_KEY=0x205f853dbfe5c84c9ef381559cfbbcee044b17b78f2bfe8f61ea004e9209d811
   SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/e909ef7e3aaa4a2cbb627fbee4ffd000
   ETHERSCAN_API_KEY=Y4M2C2HCBP7IMBWIUB79X6IJWHMAZ6U663
   OWNER=0x742d35Cc6634C0532925A3B8D4C9dB96C4B4d8B6
   ENTRYPOINT=0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789
   ```

## 🏗️ Project Structure

```
smart-contract/
├── src/
│   ├── EntryPoint.sol          # ERC-4337 EntryPoint contract
│   ├── AccountFactory.sol      # Account factory for creating wallets
│   └── SimpleAccount.sol       # Simple account implementation
├── script/
│   ├── EntryPoint.s.sol        # EntryPoint deployment script
│   ├── AccountFactory.s.sol    # AccountFactory deployment script
│   └── SimpleAccount.s.sol     # SimpleAccount deployment script
├── test/
│   ├── EntryPoint.t.sol        # EntryPoint tests
│   ├── AccountFactory.t.sol    # AccountFactory tests
│   └── SimpleAccount.t.sol     # SimpleAccount tests
└── foundry.toml               # Foundry configuration
```

## 🧪 Testing

Run all tests:

```bash
forge test
```

Run specific test file:

```bash
forge test --match-contract SimpleAccount
```

Run tests with verbose output:

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
     --verify
   ```

## 📍 Deployment Results

### Sepolia Testnet Contracts

| Contract           | Address                                      | Status                 | Etherscan                                                                               |
| ------------------ | -------------------------------------------- | ---------------------- | --------------------------------------------------------------------------------------- |
| **EntryPoint**     | `0x2A84294B123b7d48c5EB72FDf13ad035569d2a95` | ✅ Deployed & Verified | [View](https://sepolia.etherscan.io/address/0x2A84294B123b7d48c5EB72FDf13ad035569d2a95) |
| **AccountFactory** | `0x33139e3E4E5053A6efb1EA1e5c5054e5B4948B56` | ✅ Deployed & Verified | [View](https://sepolia.etherscan.io/address/0x33139e3E4E5053A6efb1EA1e5c5054e5B4948B56) |
| **SimpleAccount**  | `0xF51494f3c686c46ADe7Cb308e4438D61d6CBA3D5` | ✅ Deployed & Verified | [View](https://sepolia.etherscan.io/address/0xF51494f3c686c46ADe7Cb308e4438D61d6CBA3D5) |

### Deployment Details

- **Network**: Sepolia Testnet
- **Deployer**: `0x742d35Cc6634C0532925A3B8D4C9dB96C4B4d8B6`
- **Total Gas Used**: ~1.9M gas
- **Total Cost**: ~0.018 ETH

### Transaction Hashes

- **EntryPoint**: `0x2e04b88b59c2a3c8eabdadcf59aa7ad227b9a2e1db70bf3e91c04441f02606ca`
- **AccountFactory**: `0x14613be7403f44a1356fd5b3278bfce34cb225a08681bb0c5f80a8e101c4e70d`
- **SimpleAccount**: `0x1ccc36797527dc85d004fa2ddcf4318e6c38a3832aa6a3e5c517b266545acc80`

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
AccountFactory factory = AccountFactory(0x33139e3E4E5053A6efb1EA1e5c5054e5B4948B56);
address newAccount = factory.createAccount(owner, salt);
```

### Executing a Transaction

```solidity
// Using SimpleAccount
SimpleAccount account = SimpleAccount(0xF51494f3c686c46ADe7Cb308e4438D61d6CBA3D5);
account.execute(target, value, data);
```

### Using the Deployed SimpleAccount

```solidity
// Interact with the deployed SimpleAccount
SimpleAccount account = SimpleAccount(0xF51494f3c686c46ADe7Cb308e4438D61d6CBA3D5);

// Check owner
address owner = account.owner(); // Returns: 0x742d35Cc6634C0532925A3B8D4C9dB96C4B4d8B6

// Check entryPoint
address entryPoint = address(account.entryPoint()); // Returns: 0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789

// Check nonce
uint256 nonce = account.nonce(); // Returns: current nonce
```

## 🔒 Security Considerations

- **Private Key Management**: Never commit private keys to version control
- **Access Control**: Implement proper access controls for account operations
- **Validation**: Always validate UserOperations before execution
- **Testing**: Comprehensive test coverage for all critical functions

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

## 🏆 خطوات العمل الاحترافية (Professional Workflow)

1. **تنظيف المشروع من الملفات المؤقتة:**

   ```bash
   rm -rf cache out && find broadcast -type f -name '*.json' -delete
   ```

   > يضمن أن البناء والاختبار يتمان على كود نظيف.

2. **بناء العقود:**

   ```bash
   forge build
   ```

   > يتأكد من عدم وجود أخطاء تجميعية.

3. **تشغيل جميع الاختبارات (100% نجاح):**

   ```bash
   forge test -vvv
   ```

   > جميع اختبارات الحماية، الأداء، العمليات الجماعية، والتكامل ناجحة.

4. **النشر على شبكة Sepolia:**

   - EntryPoint:
     ```bash
     forge script script/EntryPoint.s.sol:EntryPointDeploy --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
     ```
   - AccountFactory:
     ```bash
     forge script script/AccountFactory.s.sol:AccountFactoryDeploy --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
     ```
     > SimpleAccount يُنشر عبر AccountFactory تلقائياً عند إنشاء حساب جديد.

5. **توثيق العقود على Etherscan:**
   ```bash
   forge verify-contract --chain-id 11155111 <ADDRESS> src/<Contract>.sol:<Contract> --etherscan-api-key $ETHERSCAN_API_KEY
   ```
   > تم التوثيق بنجاح للعقود المنشورة.

---

## 📍 Deployment Results (Sepolia)

| Contract           | Address                                      | Status                 | Etherscan                                                                               |
| ------------------ | -------------------------------------------- | ---------------------- | --------------------------------------------------------------------------------------- |
| **EntryPoint**     | `0x2A84294B123b7d48c5EB72FDf13ad035569d2a95` | ✅ Deployed & Verified | [View](https://sepolia.etherscan.io/address/0x2A84294B123b7d48c5EB72FDf13ad035569d2a95) |
| **AccountFactory** | `0x33139e3E4E5053A6efb1EA1e5c5054e5B4948B56` | ✅ Deployed & Verified | [View](https://sepolia.etherscan.io/address/0x33139e3E4E5053A6efb1EA1e5c5054e5B4948B56) |

- **تم نشر العقود بنجاح وتوثيقها على Etherscan.**
- جميع الاختبارات ناجحة 100%.
- الكود متوافق مع ERC-4337 بالكامل.

## 🆕 Latest Deployment (July 2024)

### New SimpleAccount Deployment

**Contract Address:** `0xF51494f3c686c46ADe7Cb308e4438D61d6CBA3D5`  
**Owner:** `0x742d35Cc6634C0532925A3B8D4C9dB96C4B4d8B6`  
**EntryPoint:** `0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789`  
**Transaction Hash:** `0x1ccc36797527dc85d004fa2ddcf4318e6c38a3832aa6a3e5c517b266545acc80`  
**Gas Used:** 1,886,994 gas  
**Cost:** 0.018183235595579766 ETH  
**Block:** 8672718  
**Status:** ✅ Deployed & Verified

**Etherscan:** [View Contract](https://sepolia.etherscan.io/address/0xF51494f3c686c46ADe7Cb308e4438D61d6CBA3D5)

### Deployment Script Features

- ✅ Professional logging with `console.logAddress`
- ✅ Environment variable validation
- ✅ Automatic deployment verification
- ✅ Comprehensive validation checks
- ✅ Gas usage tracking
- ✅ Production-ready deployment process
