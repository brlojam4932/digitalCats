const myCryptoCats = artifacts.require("myCryptoCats");

module.exports = function (deployer) {
  deployer.deploy(myCryptoCats);
};