const { MakeMinty } = require("./minty");

!(async function () {
  const minty = await MakeMinty();

  const response = await minty.createNFTFromAssetFile("logo.jpg", {
    name: "New Picture",
    description: "A simple description",
  });

  console.log(await minty.getNFTMetadata(response.tokenId));
})();
