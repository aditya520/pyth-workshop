// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
 
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
 
contract MyNFT is ERC721{

    constructor () ERC721("MyNFT", "MNFT"){
    }


    function mint() public payable {
        // mint a new NFT for $10 USD
        require(msg.value == 1 ether, "You must pay $10 to mint a new NFT");

        // mint the NFT
        _mint(msg.sender, 1);
    }
}
 