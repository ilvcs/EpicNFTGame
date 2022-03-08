import React,{useEffect,useState} from 'react';
import './App.css';

const App = () => {

  const [currentAccount, setCurrentAccount] = useState(null)
  
  // Check wallet connection when first loaded
  useEffect(() => {
    checkWalletIsConnected()
  
    
  }, [])
  

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
  return (
    <div className="App">
      <div className="container">
        <div className="header-container">
          <p className="header gradient-text">⚔️ Metaverse Slayer ⚔️</p>
          <p className="sub-text">Team up to protect the Metaverse!</p>
          <div className="connect-wallet-container">
            <img
              src="https://64.media.tumblr.com/tumblr_mbia5vdmRd1r1mkubo1_500.gifv"
              alt="Monty Python Gif"
            />

             {/*
             * Button that we will use to trigger wallet connect
             */}
            <button
              className="cta-button connect-wallet-button"
              onClick={connectWalletAction}
            >
              Connect Wallet To Kill the Boss
            </button>
          </div>
        </div>
        <div className="footer-container">
         
        </div>
      </div>
    </div>
  );
};

export default App;
