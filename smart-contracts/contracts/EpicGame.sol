// SPDX-Licence-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// Helper functions OpenZeppelin provides.
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import 'hardhat/console.sol';


contract EpicGame {

  struct CharactorAttributes is ERC721{
    uint charactorIndex;
    string name;
    string imageURI;
    uint hp;
    uint maxHp;
    uint attackDamage;
  }

  CharactorAttributes[] defaultCharactors;

  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  // Mapping from nft tokenIds and NFTAttributes;
  mapping(uint256 => CharactorAttributes) public nftHolderAttributes;

  // Mapping to address of the owner and nftTokenId
  mapping(address => uint256) public nftHolders;

  constructor(
    string[] memory characterNames,
    string[] memory characterImageURIs,
    uint[] memory charecterHp,
    uint[] memory characterAttackDmg)
    ERC721("Avatar", "AVATAR")
    {
    for(uint i = 0; i < characterNames.length; i += 1){
      defaultCharactors.push(
        CharactorAttributes({
          charactorIndex: i,
          name:characterNames[i],
          imageURI: characterImageURIs[i],
          hp: charecterHp[i],
          maxHp:charecterHp[i],
          attackDamage: characterAttackDmg[i]
        })
      );

      CharactorAttributes memory c = defaultCharactors[i];
      console.log("Done initializing %s w/ HP %s, img %s", c.name, c.hp,c.imageURI);
      //Token ids will start form 1 not 0
      _tokenIds.increment();
    }
  }

  function mintCharactorNFT(uint _characterIndex) external {
    uint256 newItemId = _tokenIds.current();
    _safeMint(msg.sender, newItemId);

    nftHolderAttributes[newItemId] = CharactorAttributes({
    charactorIndex: _characterIndex,
    name:characterNames[_characterIndex],
    imageURI: characterImageURIs[_characterIndex],
    hp: charecterHp[_characterIndex],
    maxHp:charecterHp[_characterIndex],
    attackDamage: characterAttackDmg[_characterIndex]
    })
    console.log("Minted NFT w/ tokenId %s and charactorIndex %s", newItemId, _characterIndex);
    // For easy accessing of the tokens
    nftHolders[msg.sender] = newItemId;
    _tokenIds.increment();
  }
}