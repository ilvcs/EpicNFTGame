const main = async () => {
  const gameContractFactory = await hre.ethers.getContractFactory('EpicGame')
  const gameContract = await gameContractFactory.deploy(
    ['Leo', 'Aang', 'Pikachu'], // Names
    [
      'https://i.imgur.com/pKd5Sdk.png', // Images
      'https://i.imgur.com/xVu4vFL.png',
      'https://i.imgur.com/WMB6g9u.png',
    ],
    [100, 200, 300], // HP values
    [100, 50, 25],
  )
  await gameContract.deployed()
  console.log('Contract deployed to :', gameContract.address)

  let txn
  txn = await gameContract.mintCharactorNFT(1)
  await txn.wait()
  // get the value from the nft url
  let returnedTokenURI = await gameContract.tokenURI(1)
  console.log('Token URI', returnedTokenURI)
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
