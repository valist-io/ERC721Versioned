//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./ERC721Versioned.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract VersionedItem is ERC721Versioned {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("VersionedItem", "ITM") {}

    function awardItem(address owner, string memory tokenVersion, string memory tokenURI) public returns (uint256) {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(owner, newItemId);
        _publishVersion(newItemId, tokenVersion, tokenURI);

        return newItemId;
    }

    function updateItem(uint256 itemId, string memory tokenVersion, string memory tokenURI) public {
      require(_isApprovedOrOwner(msg.sender, itemId), "caller is not owner nor approved");
      _publishVersion(itemId, tokenVersion, tokenURI);
    }
}
