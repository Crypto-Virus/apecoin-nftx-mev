# ApeCoin NFTX MEV Foundry Example

## Real Transaction Hash
0xeb8c3bebed11e2e4fcd30cbfc2fb3c55c4ca166003c7f7d319e78eaab9747098

## How to Run:


```shell
forge test -vv --fork-url <rpc-url>
```

or add below to foundry.toml then `forge test -vv`

```shell
eth_rpc_url = <rpc-url>
```


## Note:

The real transaction uses a BAYC NFT to mint 1 BAYC token that is used to pay
for redeeming NFTX fees.

In this example, you end up paying ~191 ETH to swap for 0.7 BAYC VAULT token
because there is only ~1.01 in liquidity pool. so it is cheaper to
mint BAYC Vault token using a real BAYC NFT.