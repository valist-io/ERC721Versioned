//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

/**
 * @dev ERC721 token with versioned storage based token URI management.
 */
abstract contract ERC721Versioned is ERC721URIStorage {
  using Strings for uint256;

  // mapping of keccak256(tokenId, tokenVersion) to version URIs.
  mapping(bytes32 => string) private _tokenVersionURIs;

  // mapping of tokenId to array of version names.
  mapping(uint256 => string[]) private _tokenVersionNames;

  // Published event is emitted when a new token version is published.
  event Published(address indexed _from, uint256 indexed _tokenId, string _tokenVersion, string _tokenURI);

  /**
   * @dev Returns the total number of versions for the token with the given tokenId.
   */
  function versionCount(uint256 tokenId) public view returns (uint256) {
    require(_exists(tokenId), "ERC721Versioned: version count for nonexistent token");
    return _tokenVersionNames[tokenId].length;
  }

  /**
   * @dev Returns the version name of the token with the given tokenId at the given index.
   */
  function versionNameByIndex(uint256 tokenId, uint256 index) public view returns (string memory) {
    require(index < _tokenVersionNames[tokenId].length, "ERC721Versioned: version index out of bounds");
    return _tokenVersionNames[tokenId][index];
  }

  /**
   * @dev Returns the URI of the token with the given tokenId at the given version.
   */
  function versionURI(uint256 tokenId, string memory tokenVersion) public view returns (string memory) {
    require(_exists(tokenId), "ERC721Versioned: URI query for nonexistent token");
    bytes32 selector = keccak256(abi.encodePacked(tokenId, tokenVersion));
    return _tokenVersionURIs[selector];
  }

  /**
   * @dev Add a new `tokenURI` and `tokenVersion`.  Also calls `_setTokenURI` to set the latest version.
   */
  function _publishVersion(uint256 tokenId, string memory tokenVersion, string memory tokenURI) internal virtual {
    require(_exists(tokenId), "ERC721Versioned: published version of nonexistent token");
    bytes32 selector = keccak256(abi.encodePacked(tokenId, tokenVersion));
    require(bytes(_tokenVersionURIs[selector]).length == 0, "ERC721Versioned: token version already exists");

    _tokenVersionURIs[selector] = tokenURI;
    _tokenVersionNames[tokenId].push(tokenVersion);

    _setTokenURI(tokenId, tokenURI);

    emit Published(msg.sender, tokenId, tokenVersion, tokenURI);
  }
}
