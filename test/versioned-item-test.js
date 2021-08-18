const { expect } = require("chai");

describe("VersionedItem", function () {
  it("Should create a new token", async function () {
    const VersionedItem = await ethers.getContractFactory("VersionedItem");

    const contract = await VersionedItem.deploy();
    await contract.deployed();

    const [owner] = await ethers.getSigners();
    const filter = contract.filters.Published(owner.address);

    let tokenVersion = 'v0.0.1';
    let tokenURI = 'ipfs://baf123';

    const createTx = await contract.awardItem(owner.address, tokenVersion, tokenURI);
    await createTx.wait();

    const createLogs = await contract.queryFilter(filter);
    expect(createLogs.length === 1, 'expected published event log');

    expect(createLogs[0].args._tokenVersion === tokenVersion);
    expect(createLogs[0].args._tokenURI === tokenURI);

    const tokenId = createLogs[0].args._tokenId;
    tokenVersion = 'v0.0.2';
    tokenURI = 'ipfs://baf456';

    const publishTx = await contract.updateItem(tokenId, tokenVersion, tokenURI);
    await publishTx.wait();

    const publishLogs = await contract.queryFilter(filter);
    expect(publishLogs.length === 1, 'expected published event log');

    expect(publishLogs[0].args._tokenVersion === tokenVersion);
    expect(publishLogs[0].args._tokenURI === tokenURI);
  });
});
