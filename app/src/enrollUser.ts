const FabricCAServices = require("fabric-ca-client");
const { FileSystemWallet, Gateway, X509WalletMixin, Wallets } = require("fabric-network");

const fs = require("fs");
const path = require("path");
const uuid = require("uuid");

export const enrollUser = async (userId: string, userPw: string) => {
  let ccpPath = path.resolve(
    __dirname,
    "..",
    "..",
    "network",
    "connection-profiles",
    "connection-election_commission.json"
  );
  const ccpJSON = fs.readFileSync(ccpPath, "utf8");
  const caInfo = JSON.parse(ccpJSON).certificateAuthorities["ca.election_commission"];
  const ca = new FabricCAServices(caInfo.url);
  const walletPath = path.join(__dirname, "..", "wallet");
  const wallet = await Wallets.newFileSystemWallet(walletPath);

  const userIdentity = await wallet.get(userId);

  if (userIdentity) {
    throw new Error(`An identity for the user ${userId} already exists in the wallet`);
  }

  const enrollment = await ca.enroll({
    enrollmentID: userId,
    enrollmentSecret: userPw,
  });

  let x509Identity = {
    credentials: {
      certificate: enrollment.certificate,
      privateKey: enrollment.key.toBytes(),
    },
    mspId: "ElectionCommissionMSP",
    type: "X.509",
  };

  await wallet.put(userId, x509Identity);
  console.log(
    `Successfully registered and enrolled admin user ${userId} and imported it into the wallet`
  );
};

export const registerAndEnrollUser = async (userId: string, userPw: string) => {
  try {
    let ccpPath = path.resolve(
      __dirname,
      "..",
      "..",
      "network",
      "connection-profiles",
      "connection-election_commission.json"
    );
    const ccpJSON = fs.readFileSync(ccpPath, "utf8");
    const caInfo = JSON.parse(ccpJSON).certificateAuthorities["ca.election_commission"];
    const ca = new FabricCAServices(caInfo.url);
    const walletPath = path.join(__dirname, "..", "wallet");
    const wallet = await Wallets.newFileSystemWallet(walletPath);

    const userIdentity = await wallet.get(userId);

    if (userIdentity) {
      throw new Error(`An identity for the user ${userId} already exists in the wallet`);
    }

    // Check to see if we've already enrolled the admin user.

    let adminIdentity = await wallet.get("admin");
    if (!adminIdentity) {
      throw new Error('An identity for the admin user "admin" does not exist in the wallet');
    }
    const provider = await wallet.getProviderRegistry().getProvider(adminIdentity.type);
    const adminUser = await provider.getUserContext(adminIdentity, "admin");
    const secret = await ca.register(
      {
        affiliation: "org1.department1",
        enrollmentID: userId,
        role: "client",
      },
      adminUser
    );
    const enrollment = await ca.enroll({
      enrollmentID: userId,
      enrollmentSecret: secret,
    });

    let x509Identity = {
      credentials: {
        certificate: enrollment.certificate,
        privateKey: enrollment.key.toBytes(),
      },
      mspId: "ElectionCommissionMSP",
      type: "X.509",
    };

    await wallet.put(userId, x509Identity);
    console.log(
      `Successfully registered and enrolled admin user ${userId} and imported it into the wallet`
    );
  } catch (err: any) {
    console.log("error: ", err);
    for (let i in err) {
      console.log(i, err[i]);
    }
  }
};
