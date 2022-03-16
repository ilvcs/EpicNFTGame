import React,{useEffect,useState} from 'react';
import './App.css';
import SelectCharacter from './Components/SelectCharacter'
import { CONTRACT_ADDRESS, transformCharacterData } from './constants';
import EpicGame from './utils/EpicGame.json';
import { ethers } from 'ethers';
import Arena from './Components/Arena'

const App = () => {

  const [currentAccount, setCurrentAccount] = useState(null)
  const [characterNFT, setCharacterNFT] = useState(null);
  
  // Check wallet connection when first loaded
  useEffect(() => {
    checkWalletIsConnected()

  }, [])
  
  useEffect(() => {

  if(currentAccount){
    fetchNFTMetadata()
  }
  }, [currentAccount])
  

  const checkWalletIsConnected = async() => {
    try {
      const {ethereum} = window;

    if(!ethereum){
      console.log("Makesure you connected to metamask");
    }else{
      console.log('We have the ethereum', ethereum);
      // For getting user accounts from metamask  
      const accounts = await ethereum.request({method: 'eth_accounts'})
      if(accounts.length !== 0){
        const account = accounts[0]
        console.log('Found an autharized account', account)
        setCurrentAccount(account)
      }else{
        console.log('No autharized account found')
      }

    }
    } catch (error) {
      console.log('Error while getting ethereum', error)
    }
    
  }
  const fetchNFTMetadata = async() => {
    console.log('Checking for Charactor NFT address', currentAccount)
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const signer = provider.getSigner()
    const gameContract = new ethers.Contract(
      CONTRACT_ADDRESS,
      EpicGame.abi,
      signer
    )
  
    const txn = await gameContract.checkIfUserHasNFT();
    if(txn.name){
      console.log('User has charactor NFT')
      setCharacterNFT(transformCharacterData(txn))
    }else{
      console.log('No charactor NFT found')
    }
  }
  const connectWalletAction = async() => {
    try {
      const {ethereum} = window;

      if(!ethereum){
        alert("Get Metamask")
        return
      }
      console.log('We have the metamask but need to connect to the wallet')
      const accounts = await ethereum.request({method: 'eth_requestAccounts'})
      console.log('Connected, Account:', accounts[0])
      setCurrentAccount(accounts[0])

    } catch (error) {
      console.log('Failed to connect to the metamak', error)
    }
  }

  const checkNetwork = () => {
    try {
      if(window.ethereum.networkVersion !== 4){
        alert('Please connect to Rinkbey!')
      }
    } catch (error) {
      console.log(error)
    }
  }

 
  const renderContent = () => {

    if (!currentAccount) {
      return (
        <div className="connect-wallet-container">
          <img
            src="https://64.media.tumblr.com/tumblr_mbia5vdmRd1r1mkubo1_500.gifv"
            alt="Monty Python Gif"
          />
          <button
            className="cta-button connect-wallet-button"
            onClick={connectWalletAction}
          >
            Connect Wallet To Get Started
          </button>
        </div>
      );
    } else if (currentAccount && !characterNFT) {
      return <SelectCharacter setCharacterNFT={setCharacterNFT} />;	
    /*
    * If there is a connected wallet and characterNFT, it's time to battle!
    */
    } else if (currentAccount && characterNFT) {
      return <Arena characterNFT={characterNFT} setCharacterNFT={setCharacterNFT}/>;
    }
  }; 
  return (
    <div className="App">
      <div className="container">
        <div className="header-container">
          <p className="header gradient-text">⚔️ Metaverse Slayer ⚔️</p>
          <p className="sub-text">Team up to protect the Metaverse!</p>
          {renderContent()}
        </div>
        <div className="footer-container">
         
        </div>
      </div>
    </div>
  );
};

export default App;
