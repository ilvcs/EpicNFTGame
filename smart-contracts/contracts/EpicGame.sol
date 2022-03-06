// SPDX-Licence-Identifier: UNLICENSED
// contract address: 0xF87EA159647F8BE73FFf9AA180e515E18cc44112
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// Helper functions OpenZeppelin provides.
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import 'hardhat/console.sol';
// Helper we wrote to encode in Base64
import "./libraries/Base64.sol";

contract EpicGame is ERC721{

  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  event CharacterNFTMinted(address sender, uint256 tokenId, uint256 charactorIndex);
  event AttackComplete(uint newBossHp, uint newPlayerHp);

  struct CharactorAttributes {
    uint charactorIndex;
    string name;
    string imageURI;
    uint hp;
    uint maxHp;
    uint attackDamage;
  }

  struct BigBoss {
    string name;
    string imageURI;
    uint hp;
    uint maxHp;
    uint attackDamage;
  }

  CharactorAttributes[] defaultCharactors;
  BigBoss public bigBoss;

 

  // Mapping from nft tokenIds and NFTAttributes;
  mapping(uint256 => CharactorAttributes) public nftHolderAttributes;


  // Mapping to address of the owner and nftTokenId
  mapping(address => uint256) public nftHolders;

  constructor(
    string[] memory characterNames,
    string[] memory characterImageURIs,
    uint[] memory charecterHp,
    uint[] memory characterAttackDmg,
    string memory bossName, // These new variables would be passed in via run.js or deploy.js.
    string memory bossImageURI,
    uint bossHp,
    uint bossAttackDamage
  )
    ERC721("Avatar Game NFT", "AVATAR")
    {
      // Initialize the boss. Save it to our global "bigBoss" state variable.
      bigBoss = BigBoss({
        name: bossName,
        imageURI: bossImageURI,
        hp: bossHp,
        maxHp: bossHp,
        attackDamage: bossAttackDamage
      });

      console.log("Done initializing boss %s w/ HP %s, img %s", bigBoss.name, bigBoss.hp, bigBoss.imageURI);
      // For user chrectors
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
    // Emit the event so that world will know that we have successfully minted
    emit CharacterNFTMinted(msg.sender, newItemId, _characterIndex);
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

  function checkIfUserHasNFT() public view returns (CharactorAttributes memory) {
    // Get the tokenId of the user's character NFT
    uint256 userNftTokenId = nftHolders[msg.sender];
    // Return their chrector nft data if the user is having token.
    if (userNftTokenId > 0) {
      return nftHolderAttributes[userNftTokenId];
    }
    // else return empty charactor .
    else {
      CharactorAttributes memory emptyStruct;
      return emptyStruct;
    }
  }

  function getAllDefaultCharacters() public view returns (CharactorAttributes[] memory) {
    return defaultCharactors;
  }

  function attackBoss() public {
    // get the state of the player NFT
    uint256 nftTokenIdOfPlayer = nftHolders[msg.sender];
    CharactorAttributes storage player = nftHolderAttributes[nftTokenIdOfPlayer];
    console.log("\nPlayer w/ character %s about to attack. Has %s HP and %s AD", player.name, player.hp, player.attackDamage);
    console.log("Boss %s has %s HP and %s AD", bigBoss.name, bigBoss.hp, bigBoss.attackDamage);

    // Make sure the player has more than 0 HP.
    require (
      player.hp > 0,
      "Error: character must have HP to attack boss."
    );

    // Make sure the boss has more than 0 HP.
    require (
      bigBoss.hp > 0,
      "Error: boss must have HP to attack boss."
    );

      // Allow player to attack boss.
    if (bigBoss.hp < player.attackDamage) {
      bigBoss.hp = 0;
    } else {
      bigBoss.hp = bigBoss.hp - player.attackDamage;
    }

    // Allow boss to attack player.
    if (player.hp < bigBoss.attackDamage) {
      player.hp = 0;
    } else {
      player.hp = player.hp - bigBoss.attackDamage;
    }

    emit AttackComplete(bigBoss.hp, player.hp);

    console.log("Player attacked boss. New boss hp: %s", bigBoss.hp);
    console.log("Boss attacked player. New player hp: %s\n", player.hp);
  }
  // Return bosy data
  function getBigBoss() public view returns (BigBoss memory) {
    return bigBoss;
  }

}