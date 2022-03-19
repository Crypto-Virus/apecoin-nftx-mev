// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import "v2-core/interfaces/IUniswapV2Factory.sol";
import "v2-core/interfaces/IUniswapV2Pair.sol";
import "v2-core/interfaces/IUniswapV2Callee.sol";

import { console } from "./test/utils/console.sol";

interface INFTXVault {
    function redeem(uint256 amount, uint256[] calldata specificIds) external returns (uint256[] calldata);
}

interface AirdropContract {
    function claimTokens() external;
}

contract ApeMev is Ownable, IUniswapV2Callee {

    // flashloan bayc
    // swap bayc token for nft
    // claim airdrop
    // swap nft for bayc token
    // return loan

    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant BAYC_NTFX_ERC20_ADDRESS = 0xEA47B64e1BFCCb773A0420247C0aa0a3C1D2E5C5;
    uint256 private constant NFTX_BAYC_VAULT_ID = 2;

    IUniswapV2Factory private constant SUSHI_FACTORY = IUniswapV2Factory(0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac);
    INFTXVault private constant INFTX_Vault = INFTXVault(0x3451b4c5395B3fE06aA629af73207cfaA28131D1);
    IERC20 private constant BAYC_VAULT_TOKEN = IERC20(BAYC_NTFX_ERC20_ADDRESS);


    AirdropContract private constant AIRDROP = AirdropContract(0x025C6da5BD0e6A5dd1350fda9e3B6a614B205a1F);


    function start() external onlyOwner {
        console.log("Starting MEV");
        getLoan();
    }

    function getLoan() internal {
        console.log("Requesting flash swap");
        uint256 amount = 1 ether;

        // get pair
        address pairAddr = SUSHI_FACTORY.getPair(BAYC_NTFX_ERC20_ADDRESS, WETH);
        require(pairAddr != address(0), "!pair");

        IUniswapV2Pair pair = IUniswapV2Pair(pairAddr);
        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = pair.getReserves();
        console.log("reserves", reserve0, reserve1);
        address token0 = pair.token0();
        address token1 = pair.token1();
        console.log("tokens", token0, token1);
        uint256 amount0Out = BAYC_NTFX_ERC20_ADDRESS == token0 ? amount : 0;
        uint256 amount1Out = BAYC_NTFX_ERC20_ADDRESS == token1 ? amount : 0;

        // need to pass some data to trigger uniswapV2Call
        bytes memory data = abi.encode(BAYC_NTFX_ERC20_ADDRESS, amount, address(SUSHI_FACTORY));
        pair.swap(amount0Out, amount1Out, address(this), data);
    }

    function uniswapV2Call(
        address sender,
        uint amount0,
        uint amount1,
        bytes calldata data
    ) external override {
        console.log("Received funds from flashswap");
        require(sender == address(this), "!sender");

        address token0 = IUniswapV2Pair(msg.sender).token0();
        address token1 = IUniswapV2Pair(msg.sender).token1();
        address pair = SUSHI_FACTORY.getPair(token0, token1);
        require(msg.sender == pair, "!pair");

        // decode data
        (address tokenBorrow, uint256 amount, address factoryAddr) = abi.decode(data, (address, uint256, address));

        uint256 fee = ((amount * 3) / 997) + 1;
        uint256 repayAmount = amount + fee;

        SwapForApe();
        repayLoan(pair, repayAmount);
    }

    function SwapForApe() internal {
        console.log("Swapping bayc tokens for nfts");
        uint256 amount = 5; // todo: calcualte amount somehow
        uint256[] memory specifiedIds = new uint[](0);

        BAYC_VAULT_TOKEN.approve(address(INFTX_Vault), type(uint256).max);
        console.log("Redeeming");
        INFTX_Vault.redeem(amount, specifiedIds);

        claimTokens();
    }

    function claimTokens() internal {
        console.log("Claiming airdrop");
        AIRDROP.claimTokens();

    }

    function repayLoan(address pair, uint256 repayAmount) internal {
        console.log("repaying flashswap");

    }

}