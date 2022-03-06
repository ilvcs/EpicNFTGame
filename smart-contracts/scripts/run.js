const main = async () => {
  const gameContractFactory = await hre.ethers.getContractFactory('EpicGame')


  const gameContract = await gameContractFactory.deploy(                        
    ["Leo", "Aang", "Pikachu"], // Users names       
    ["https://i.imgur.com/pKd5Sdk.png", // User charectors iamges
    "https://i.imgur.com/xVu4vFL.png", // User charectors iamges
    "https://i.imgur.com/u7T87A6.png"],// User charectors iamges
    [100, 200, 300], // User HP                   
    [100, 50, 25],// User Attack damage
    "Thanos", // Boss name
    "https://imgur.com/gallery/CFzrs", // Boss image
    10000, // Boss hp
    50 // Boss attack damage
  );
 
  await gameContract.deployed()
  console.log('Contract deployed to :', gameContract.address)

  let txn
  txn = await gameContract.mintCharactorNFT(1)
  await txn.wait()

  // Simulating attacks
  txn = await gameContract.attackBoss();
  await txn.wait();

  txn = await gameContract.attackBoss();
  await txn.wait();

  txn = await gameContract.attackBoss();
  await txn.wait();

  // get the value from the nft url
  // let returnedTokenURI = await gameContract.tokenURI(1)
  // console.log('Token URI', returnedTokenURI)
}

const runMain = async () => {
  try {
    await main()
    process.exit(0)
  } catch (error) {
    console.log(error)
    process.exit(1)
  }
}

runMain()
