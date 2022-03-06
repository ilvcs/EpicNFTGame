// SPDX-Licence-Identifier: UNLICENSED
// contract address: 0x38435745Fc0fb734F862A5e4Fe2C30c47CdF3E4b
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// Helper functions OpenZeppelin provides.
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import 'hardhat/console.sol';
// Helper we wrote to encode in Base64
import "./libraries/Base64.sol";

contract EpicGame is ERC721{

  struct CharactorAttributes {
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
    uint[] memory characterAttackDmg
  )
    ERC721("Avatar Game NFT", "AVATAR")
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
    name:defaultCharactors[_characterIndex].name,
    imageURI: defaultCharactors[_characterIndex].imageURI,
    hp: defaultCharactors[_characterIndex].hp,
    maxHp:defaultCharactors[_characterIndex].maxHp,
    attackDamage: defaultCharactors[_characterIndex].attackDamage
    });
    console.log("Minted NFT w/ tokenId %s and charactorIndex %s", newItemId, _characterIndex);
    // For easy accessing of the tokens
    nftHolders[msg.sender] = newItemId;
    _tokenIds.increment();
  }

  function tokenURI(uint256 _tokenId) public view override returns (string memory){
    CharactorAttributes memory charAttributes = nftHolderAttributes[_tokenId];

    string memory strHp = Strings.toString(charAttributes.hp);
    string memory strMaxHp = Strings.toString(charAttributes.maxHp);
    string memory strAttackDamage = Strings.toString(charAttributes.attackDamage);

    string memory json = Base64.encode(
      abi.encodePacked(
      '{"name": "',
      charAttributes.name,
      ' -- NFT #: ',
      Strings.toString(_tokenId),
      '", "description": "This is an NFT that lets people play in the game EpicGame!", "image": "',
      charAttributes.imageURI,
      '", "attributes": [ { "trait_type": "Health Points", "value": ',strHp,', "max_value":',strMaxHp,'}, { "trait_type": "Attack Damage", "value": ',
      strAttackDamage,'} ]}'
    )
    );

    string memory output = string(abi.encodePacked("data:application/json;base64,", json));
    return output;
  }
}