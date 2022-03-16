import React, { useEffect, useState } from 'react';
import './SelectCharacter.css';
import { ethers } from 'ethers';
import { CONTRACT_ADDRESS, transformCharacterData } from '../../constants';
import EpicGame from '../../utils/EpicGame.json';

const SelectCharacter = ({setCharacterNFT}) => {
  const [characters, setCharacters] = useState([]);
  const [gameContract, setGameContract] = useState(null);

  useEffect(() => {
    const {ethereum} = window
    if(ethereum){
      const provider = new ethers.providers.Web3Provider(ethereum)
    
      const signer = provider.getSigner()
      const gameContract = new ethers.Contract(
        CONTRACT_ADDRESS, EpicGame.abi, signer
      )
      setGameContract(gameContract)
    }else{
      console.log('NO ethereum object found');
    }
  
    
  }, [])

  useEffect(() => {
    const getCharactors = async()=> {

      try {
        console.log('Getting contract charactor to mint');
        const charactersTxn = await gameContract.getAllDefaultCharacters();
        console.log('charactersTxn:', charactersTxn);

        const characters = charactersTxn.map((characterData) =>
        transformCharacterData(characterData)
        
      );
      setCharacters(characters);
      } catch (error) {
        console.error('Oops! Something went wrong fetching characters:', error);
      }
    }

    /*
    * Callback method that will fire when this event is received
    */

    const onCharacterMint = async(sender, tokenId, characterIndex) =>{
      console.log( `CharacterNFTMinted - sender: ${sender} tokenId: ${tokenId.toNumber()} characterIndex: ${characterIndex.toNumber()}`)
      /*
      * Once our character NFT is minted we can fetch the metadata from our contract
      * and set it in state to move onto the Arena
      */
      if (gameContract) {
        const characterNFT = await gameContract.checkIfUserHasNFT();
        console.log('CharacterNFT: ', characterNFT);
        setCharacterNFT(transformCharacterData(characterNFT));
      }
    }
  
    if (gameContract) {
      getCharactors();
        /*
      * Setup NFT Minted Listener
      */
      gameContract.on('CharacterNFTMinted', onCharacterMint);
    }
    return () => {
      /*
       * When your component unmounts, let;s make sure to clean up this listener
       */
      if (gameContract) {
        gameContract.off('CharacterNFTMinted', onCharacterMint);
      }
    };
  }, [gameContract])

  const mintCharacterNFTAction = async(charactorId) =>{
    try {
      if(gameContract){
        console.log('Minting charactor...')
        const mintTxn = await gameContract.mintCharactorNFT(charactorId)
        await mintTxn.wait()
        console.log('Mint Txn', mintTxn)
      }
    } catch (error) {
      console.log('mintCharacterNFTAction Error', error)
    }
  }

  const renderCharacters = () =>
    characters.map((character, index) => (
      <div className="character-item" key={character.name}>
        <div className="name-container">
          <p>{character.name}</p>
        </div>
        <img src={character.imageURI} alt={character.name} />
        <button
          type="button"
          className="character-mint-button"
          onClick={()=> mintCharacterNFTAction(index)}
        >{`Mint ${character.name}`}</button>
      </div>
  ));
  
  return(
    <div className="select-character-container">
      <h2>Mint your hero. Chose Wisely</h2>
      {characters.length > 0 && (
      <div className="character-grid">{renderCharacters()}</div>
    )}
    </div>
  )
}
export default SelectCharacter