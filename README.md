# DeFiLabs

In-progress.

This repo aim to learn DeFi projects; how the functionality works, on-chain testing, bug finding, fuzzing, CI, etc.

## Getting Started

* Follow the [instructions](https://book.getfoundry.sh/getting-started/installation.html) to install [Foundry](https://github.com/foundry-rs/foundry).

* Clone and install dependencies:```git submodule update --init --recursive```

* To see function signatures you shoul add `--etherscan-api-key YOURAPIKEY` at the end of the `forge test`, you coul get an API key on https://etherscan.io/myapikey

### FlashLoan Testing

UniSwapV2 FlashSwap Testing
```sh
forge test --contracts ./src/test/Uniswapv2_flashswap.sol -vv
```

DODO FlashLoan Testing
```sh
forge test --contracts ./src/test/DODO_flashloan.sol -vv
```

AAVE FlashLoan Testing
```sh
forge test --contracts ./src/test/Aave_flashloan.sol -vv

```

Balancer FlashLoan Testing
```sh
forge test --contracts ./src/test/Balancer_flashloan.sol -vv
```

Pancakeswap FlashSwap Testing
```sh
forge test --contracts ./src/test/Pancakeswap_flashswap.sol -vv
```

Biswap FlashSwap Testing
```sh
forge test --contracts ./src/test/Biswap_flashloan.sol -vv
```
### ChainLink Testing
getLatestPrice | more tests in-progress
```sh
forge test --contracts ./src/test/Chainlink.sol -vv
```
### Compound Testing
ERC20 - cToken Supply/Redeem/Borrow/Repay | more tests in-progress
```sh
forge test --contracts ./src/test/Compound.sol -vv
```
Goverance - submit proposal | more tests in-progress
```sh
forge test --contracts ./src/test/Compound-dao.sol -vv
```
### UniswapV2 Testing
Swap | more tests in-progress
```sh
forge test --contracts ./src/test/Uniswapv2.sol -vv
```
### Curve Testing
Swap | more tests in-progress
```sh
forge test --contracts ./src/test/Curve.sol -vv
```
### MakerDAO Testing
### Balancer Testing
