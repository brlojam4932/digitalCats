const myCryptoCats = artifacts.require("myCryptoCats");

"dependencies": {
  "@openzeppelin/contracts": ">=4.3.1"
}

module.exports = function (deployer) {
  deployer.deploy(myCryptoCats);
  
};
