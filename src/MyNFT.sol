// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {IEntropyConsumer} from "@pythnetwork/entropy-sdk-solidity/IEntropyConsumer.sol";
import {IEntropy} from "@pythnetwork/entropy-sdk-solidity/IEntropy.sol";

contract MyNFT is ERC721, IEntropyConsumer {
    IEntropy entropy;
    address provider;

    constructor(address _entropy, address _provider) ERC721("MyNFT", "MNFT") {
        entropy = IEntropy(_entropy);
        provider = _provider;
    }

    function mint(uint256 randomTokenId) public {
        // mint the NFT
        _mint(msg.sender, randomTokenId);
    }

    function fetchEntropyRandomNumber(
        bytes32 userRandomNumber
    ) external payable {
        // get the required fee
        uint128 requestFee = entropy.getFee(provider);
        // check if the user has sent enough fees
        if (msg.value < requestFee) revert("not enough fees");

        // pay the fees and request a random number from entropy
        uint64 sequenceNumber = entropy.requestWithCallback{value: requestFee}(
            provider,
            userRandomNumber
        );
    }


    function entropyCallback(uint64, address, bytes32 randomNumber) internal override {
        // do something with the random number
        mint(uint256(randomNumber));
    }

    function getEntropy() internal view override returns (address) {
        return address(entropy);
    }

}
