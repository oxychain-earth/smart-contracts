const { expect } = require("chai");
const { ethers } = require("hardhat");

let oxyToken;
let projectId;
let tokenId;
let amount = 1000;
let serialNumber = "ABCD1000";

describe("OXYToken", function () {
  it("createProject", async function () {

    const OXYToken = await ethers.getContractFactory("OXYToken");
    oxyToken = await OXYToken.deploy();
    await oxyToken.deployed();

    let createProjectTx = await oxyToken.createProject();
    await createProjectTx.wait();

    projectId = await oxyToken.projectsCreated();
    expect(projectId).to.equal(1);
  });

  it("createNewTokenBatch", async function () {

    let createTokenTx = await oxyToken.createNewTokenBatch(projectId);
    await createTokenTx.wait();

    tokenId = await oxyToken.tokenIds();
    expect(tokenId).to.equal(1);   
  });

  it("mint", async function () {
    
    let mintTx = await oxyToken.mint(tokenId, amount, serialNumber);
    await mintTx.wait();

    let tokenAmount = away oxyToken.tokenIdsToAmounts(tokenId);
    let tokenSerialNumber = away oxyToken.tokenToSerialNumber(tokenId);
    expect(tokenAmount).to.equal(amount);
    expect(tokenSerialNumber).to.equal(serialNumber);
  });
});