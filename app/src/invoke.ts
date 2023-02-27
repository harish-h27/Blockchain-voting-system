const { Gateway, Wallets } = require("fabric-network");
import fs from "fs";
import path from "path";

export const invokeTransaction = async (username: string, params: any[]) => {
  let ccpPath = path.resolve(
    __dirname,
    "..",
    "..",
    "network",
    "connection-profiles",
    "connection-election_commission.json"
  );
  const ccp = JSON.parse(fs.readFileSync(ccpPath, "utf8"));
  const walletPath = path.join(__dirname, "..", "wallet");
  const wallet = await Wallets.newFileSystemWallet(walletPath);
  // Check to see if we've already enrolled the user.
  let identity = await wallet.get(username);
  if (!identity) {
    throw new Error(
      `An identity for the user ${username} does not exist in the wallet, so registering user`
    );
  }
  const connectOptions = {
    wallet,
    identity: username,
    discovery: { enabled: true, asLocalhost: true },
  };
  const gateway = new Gateway();
  await gateway.connect(ccp, connectOptions);
  const network = await gateway.getNetwork("mychannel");
  const contract = network.getContract("decentralized_voting");
  let fnname = params[0];
  params.shift();
  console.log("invoking transaction: function name:", fnname, " params: ", params);
  let result = await contract.submitTransaction(fnname, ...params);
  await gateway.disconnect();
  result = result.toString();
  return JSON.parse(result);
};

// event listener
// contract.addContractListener(async (event: any) => {
//     console.log('44: ', event.chaincodeId)
//     console.log('45: ', event.eventName);
//     const asset = JSON.parse(event.payload.toString());
//     console.log('47: ', asset);

//     const eventTransaction = event.getTransactionEvent();
//     const blockEvent = eventTransaction.getBlockEvent();
//     const contractEvent = eventTransaction.getContractEvents();

//     console.log('53: ', blockEvent)
//     console.log('54: ', contractEvent);
//   console.log('50: ', eventTransaction);
// })
