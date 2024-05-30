// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@pythnetwork/pyth-sdk-solidity/IPyth.sol";

contract MyNFT is ERC721 {
    IPyth pyth;

    constructor(address _pyth) ERC721("MyNFT", "MNFT") {
        pyth = IPyth(_pyth);
    }

    function mint(
        bytes32 ethUsdPriceId,
        bytes[] calldata priceUpdate
    ) public payable {
        PythStructs.Price memory assetPrice = fetchPrices(
            ethUsdPriceId,
            priceUpdate
        );

        // Converting the price to 10 USD in wei
        uint tenDollarsInWei = _convertPythPriceToXUSD(assetPrice, 10);


        // mint a new NFT for $10 USD
        require(
            msg.value >= tenDollarsInWei,
            "You must pay atleast $10 to mint a new NFT"
        );

        // mint the NFT
        _mint(msg.sender, 1);
    }

    function fetchPrices(
        bytes32 ethUsdPriceId,
        bytes[] calldata priceUpdate
    ) public payable returns (PythStructs.Price memory) {
        uint updateFee = pyth.getUpdateFee(priceUpdate);
        pyth.updatePriceFeeds{value: updateFee}(priceUpdate);

        PythStructs.Price memory price = pyth.getPrice(ethUsdPriceId);

        return price;
    }

    // Helper method to convert the price to X USD in wei
    function _convertPythPriceToXUSD(
        PythStructs.Price memory price,
        uint amount
    ) internal pure returns (uint) {
        uint ethPrice18Decimals = (uint(uint64(price.price)) * (10 ** 18)) /
            (10 ** uint8(uint32(-1 * price.expo)));
        return (amount * 10 ** 18) / ethPrice18Decimals;
    }
}



/* Price Object Format
{
  price: {
    price: 383104099657,
    conf: 308900343,
    expo: -8,
    publishTime: 1716921239,
  },
}
*/
