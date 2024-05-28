// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {MyNFT} from "../src/MyNFT.sol";
import {MockPyth} from "@pythnetwork/pyth-sdk-solidity/MockPyth.sol";

contract MyNFTTest is Test {
    MyNFT public nft;
    MockPyth public pyth;
    bytes32 ETH_PRICE_FEED_ID = bytes32(uint256(0x1));

    uint256 ETH_TO_WEI = 10 ** 18;

    function setUp() public {
        pyth = new MockPyth(60, 1);

        nft = new MyNFT(address(pyth));
        console2.log("MyNFT deployed at address: {}", address(nft));
    }

    function createEthUpdate(
        int64 ethPrice
    ) private view returns (bytes[] memory) {
        bytes[] memory updateData = new bytes[](1);
        updateData[0] = pyth.createPriceFeedUpdateData(
            ETH_PRICE_FEED_ID,
            ethPrice * 100000, // price
            10 * 100000, // confidence
            -5, // exponent
            ethPrice * 100000, // emaPrice
            10 * 100000, // emaConfidence
            uint64(block.timestamp), // publishTime
            uint64(block.timestamp) // prevPublishTime
        );

        return updateData;
    }

    function setEthPrice(int64 ethPrice) private {
        bytes[] memory updateData = createEthUpdate(ethPrice);
        uint value = pyth.getUpdateFee(updateData);
        vm.deal(address(this), value);
        pyth.updatePriceFeeds{value: value}(updateData);
    }

    function testMintOneEther() public {
        setEthPrice(100);
        vm.deal(address(this), ETH_TO_WEI);

        bytes[] memory updateData = createEthUpdate(100);

        nft.mint{value: 1 ether}(ETH_PRICE_FEED_ID, updateData);
        console2.log("NFT minted");
    }
}
