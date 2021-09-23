async function main() {
    // We get the contract to deploy
    const OXYToken = await ethers.getContractFactory("OXYToken");
    const oxyToken = await OXYToken.deploy();
  
    console.log("OXY example token deployed to:", oxyToken.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
