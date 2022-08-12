# DeFiLabs
## Getting Started

* Follow the [instructions](https://book.getfoundry.sh/getting-started/installation.html) to install [Foundry](https://github.com/foundry-rs/foundry).

* Clone and install dependencies:```git submodule update --init --recursive```

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


