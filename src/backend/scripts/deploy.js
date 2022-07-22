async function main () {
    const [deployer] = await ethers.getSigners();

    console.log("Deploying acoount : ", deployer.address);
    console.log("Balance : ", (await deployer.getBalance()).toString());

    const NFT = await ethers.getContractFactory("NFT");
    const nft = await NFT.deploy();

    const Marketplace = await ethers.getContractFactory("Marketplace");
    const marketplace = await Marketplace.deploy(1);

    console.log("NFT contract address : ", nft.address);
    console.log("Marketplace address : ", marketplace.address);

    saveFrontendFiles(nft, "NFT");
    saveFrontendFiles(marketplace, "Marketplace");

}

function saveFrontendFiles(contract, name) {
    const fs = require("fs");

    const contractsDir = __dirname + "/../../frontend/contractsData";

    if (!fs.existsSync(contractsDir)) {
        fs.mkdirSync(contractsDir);
    }

    fs.writeFileSync(
        contractsDir + `/${name}-address.json`,
        JSON.stringify({address : contract.address}, undefined, 2)
    );

    const contractArtifact = artifacts.readArtifactSync(name);

    fs.writeFileSync(
        contractsDir + `/${name}.json`,
        JSON.stringify(contractArtifact, undefined, 2)
    );
}


main().then(() => process.exit(0)).catch(err => {
    console.log(err);
    process.exit(1);
});

