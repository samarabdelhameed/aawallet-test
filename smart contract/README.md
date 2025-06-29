## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

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

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

# SimpleAccount Project

This project demonstrates deploying and verifying a minimal ERC-4337-style Account contract on Sepolia testnet using Foundry.

## How to Deploy and Verify

1. **Deploy the contract:**

   ```sh
   forge script script/SimpleAccount.s.sol:SimpleAccountScript --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast
   ```

2. **Verify the contract on Etherscan:**
   ```sh
   forge verify-contract 0xF45C3cC65C342CD316970F72E4C835CAC0533010 src/SimpleAccount.sol:SimpleAccount --chain-id 11155111 --etherscan-api-key Y4M2C2HCBP7IMBWIUB79X6IJWHMAZ6U663 --compiler-version v0.8.30+commit.5feceb7b --constructor-args 00000000000000000000000014D7795A2566Cd16eaA1419A26ddB643CE523655
   ```

**Verification Output:**

```
Start verifying contract `0xF45C3cC65C342CD316970F72E4C835CAC0533010` deployed on sepolia
Compiler version: v0.8.30+commit.5feceb7b
Constructor args: 00000000000000000000000014D7795A2566Cd16eaA1419A26ddB643CE523655

Submitting verification for [src/SimpleAccount.sol:SimpleAccount] 0xF45C3cC65C342CD316970F72E4C835CAC0533010.
Submitted contract for verification:
        Response: `OK`
        GUID: `zhcbdvc4gwquhxtj7qujepcwgykh2exbcdfr4rnmjkjcrwwihr`
        URL: https://sepolia.etherscan.io/address/0xf45c3cc65c342cd316970f72e4c835cac0533010
```

---

## شرح مختصر بالعربي

- إذا واجهت مشكلة في التحقق على Etherscan، تأكد من تمرير معاملات الـ constructor بشكل صحيح كما في الأمر أعلاه.
- انتظر دقيقة أو اثنتين بعد التحقق ثم حدّث صفحة العقد على Etherscan.
- إذا لم يظهر الكود، أعد تنفيذ أمر التحقق مع معاملات الـ constructor.

---

**Contact:** samarabdelhameed
