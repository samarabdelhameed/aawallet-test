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
     --verify \
     -vvvv
   ```

## 📍 Deployment Results

### Sepolia Testnet Contracts

| Contract           | Address                                      | Status                 | Etherscan                                                                               |
| ------------------ | -------------------------------------------- | ---------------------- | --------------------------------------------------------------------------------------- |
| **EntryPoint**     | `0x2A84294B123b7d48c5EB72FDf13ad035569d2a95` | ✅ Deployed & Verified | [View](https://sepolia.etherscan.io/address/0x2A84294B123b7d48c5EB72FDf13ad035569d2a95) |
| **AccountFactory** | `0x33139e3E4E5053A6efb1EA1e5c5054e5B4948B56` | ✅ Deployed & Verified | [View](https://sepolia.etherscan.io/address/0x33139e3E4E5053A6efb1EA1e5c5054e5B4948B56) |
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
