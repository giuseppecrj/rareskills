const fs = require("fs/promises");
const path = require("path");

const CID = require("cids");
const ipfsClient = require("ipfs-http-client");
const all = require("it-all");

const uint8ArrayConcat = require("uint8arrays/concat");
const uint8ArrayToString = require("uint8arrays/to-string");
const { BigNumber } = require("ethers");

const { loadDeploymentInfo } = require("./deploy");

// The getconfig package loads configuration from files located in the the `config` directory.
// See https://www.npmjs.com/package/getconfig for info on how to override the default config for
// different environments (e.g. testnet, mainnet, staging, production, etc).
const config = require("getconfig");

// ipfs.add parameters for more deterministic CIDs
const ipfsAddOptions = {
  cidVersion: 1,
  hashAlg: "sha2-256",
};

async function MakeMinty() {
  const minty = new Minty();
  await minty.init();
  return minty;
}

class Minty {
  constructor() {
    this.ipfs = null;
    this.contract = null;
    this.deploymentInfo = null;
    this._initialized = false;
  }

  async init() {
    if (this._initialized) {
      return;
    }

    this.ethers = require("ethers");

    // The Minty object expects that the contract has already been deployed, with
    // details written to a deployment info file. The default location is `./minty-deployment.json`,
    // in the config.
    this.deployInfo = await loadDeploymentInfo();

    // // connect to the smart contract using the address and ABI from the deploy info
    const { abi, address } = this.deployInfo.contract;

    this.provider = new this.ethers.providers.JsonRpcProvider();
    this.signer = new this.ethers.Wallet(config.privateKey, this.provider);
    this.contract = await new this.ethers.Contract(address, abi, this.provider);

    // // create a local IPFS node
    this.ipfs = ipfsClient(config.ipfsApiUrl);

    this._initialized = true;
  }

  async createNFTFromAssetData(content, options) {
    const filePath = options.path || "asset.bin";
    const basename = path.basename(filePath);

    // When you add an object to IPFS with a directory prefix in its path,
    // IPFS will create a directory structure for you. This is nice, because
    // it gives us URIs with descriptive filenames in them e.g.
    // 'ipfs://QmaNZ2FCgvBPqnxtkbToVVbK2Nes6xk5K4Ns6BsmkPucAM/cat-pic.png' instead of
    // 'ipfs://QmaNZ2FCgvBPqnxtkbToVVbK2Nes6xk5K4Ns6BsmkPucAM'
    const ipfsPath = "/nft/" + basename;
    const { cid: assetCid } = await this.ipfs.add(
      { path: ipfsPath, content },
      ipfsAddOptions,
    );

    // make the NFT metadata JSON
    const assetURI = ensureIpfsUriPrefix(assetCid) + "/" + basename;
    const metadata = await this.makeNFTMetadata(assetURI, options);

    // add the metadata to IPFS
    const { cid: metadataCid } = await this.ipfs.add(
      { path: "/nft/metadata.json", content: JSON.stringify(metadata) },
      ipfsAddOptions,
    );
    const metadataURI = ensureIpfsUriPrefix(metadataCid) + "/metadata.json";

    // get the address of the token owner from options, or use the default signing address if no owner is given
    let ownerAddress = options.owner;
    if (!ownerAddress) {
      ownerAddress = await this.defaultOwnerAddress();
    }

    // mint a new token referencing the metadata URI
    const tokenId = await this.mintToken(ownerAddress, metadataURI);

    return {
      tokenId,
      ownerAddress,
      metadata,
      assetURI,
      metadataURI,
      assetGatewayURL: makeGatewayURL(assetURI),
      metadataGatewayURL: makeGatewayURL(metadataURI),
    };
  }

  async createNFTFromAssetFile(filename, options) {
    const content = await fs.readFile(filename);
    return this.createNFTFromAssetData(content, { ...options, path: filename });
  }

  async makeNFTMetadata(assetURI, options) {
    const { name, description } = options;
    assetURI = ensureIpfsUriPrefix(assetURI);
    return {
      name,
      description,
      image: assetURI,
    };
  }

  async defaultOwnerAddress() {
    return this.signer.address;
  }

  async mintToken(ownerAddress, metadataURI) {
    // the smart contract adds an ipfs:// prefix to all URIs, so make sure it doesn't get added twice
    metadataURI = stripIpfsUriPrefix(metadataURI);

    // Call the mintToken method to issue a new token to the given address
    // This returns a transaction object, but the transaction hasn't been confirmed
    // yet, so it doesn't have our token id.
    const contract = this.contract.connect(this.signer);

    const tx = await contract.mint(ownerAddress, metadataURI);

    // The OpenZeppelin base ERC721 contract emits a Transfer event when a token is issued.
    // tx.wait() will wait until a block containing our transaction has been mined and confirmed.
    // The transaction receipt contains events emitted while processing the transaction.
    const receipt = await tx.wait();

    for (const event of receipt.events) {
      if (event.event !== "Transfer") {
        console.log("ignoring unknown event type ", event.event);
        continue;
      }
      return event.args.tokenId.toString();
    }

    throw new Error("unable to get token id");
  }

  async getNFTMetadata(tokenId) {
    const metadataURI = await this.contract.tokenURI(tokenId);
    const metadata = await this.getIPFSJSON(metadataURI);

    return { metadata, metadataURI };
  }

  async getIPFSString(cidOrURI) {
    const bytes = await this.getIPFS(cidOrURI);
    return uint8ArrayToString(bytes);
  }

  async getIPFS(cidOrURI) {
    const cid = stripIpfsUriPrefix(cidOrURI);
    return uint8ArrayConcat(await all(this.ipfs.cat(cid)));
  }

  async getIPFSJSON(cidOrURI) {
    const str = await this.getIPFSString(cidOrURI);
    return JSON.parse(str);
  }
}

//////////////////////////////////////////////
// -------- URI helpers
//////////////////////////////////////////////

/**
 * @param {string} cidOrURI either a CID string, or a URI string of the form `ipfs://${cid}`
 * @returns the input string with the `ipfs://` prefix stripped off
 */
function stripIpfsUriPrefix(cidOrURI) {
  if (cidOrURI.startsWith("ipfs://")) {
    return cidOrURI.slice("ipfs://".length);
  }
  return cidOrURI;
}

function ensureIpfsUriPrefix(cidOrURI) {
  let uri = cidOrURI.toString();
  if (!uri.startsWith("ipfs://")) {
    uri = "ipfs://" + cidOrURI;
  }
  // Avoid the Nyan Cat bug (https://github.com/ipfs/go-ipfs/pull/7930)
  if (uri.startsWith("ipfs://ipfs/")) {
    uri = uri.replace("ipfs://ipfs/", "ipfs://");
  }
  return uri;
}

/**
 * Return an HTTP gateway URL for the given IPFS object.
 * @param {string} ipfsURI - an ipfs:// uri or CID string
 * @returns - an HTTP url to view the IPFS object on the configured gateway.
 */
function makeGatewayURL(ipfsURI) {
  return config.ipfsGatewayUrl + "/" + stripIpfsUriPrefix(ipfsURI);
}

/**
 *
 * @param {string} cidOrURI - an ipfs:// URI or CID string
 * @returns {CID} a CID for the root of the IPFS path
 */
function extractCID(cidOrURI) {
  // remove the ipfs:// prefix, split on '/' and return first path component (root CID)
  const cidString = stripIpfsUriPrefix(cidOrURI).split("/")[0];
  return new CID(cidString);
}

module.exports = {
  MakeMinty,
};
