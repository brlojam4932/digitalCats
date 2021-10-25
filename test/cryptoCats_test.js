const myCryptoCats = artifacts.require("myCryptoCats");

const {
    BN,           // Big Number support
    constants,    // Common constants, like the zero address and largest integers
    expectEvent,  // Assertions for emitted events
    expectRevert, // Assertions for transactions that should fail
  } = require('@openzeppelin/test-helpers');

contract("CryptoCats", ([owner, alfa, beta, charlie]) => {
    // Global variable declarations
    let contractInstance;
    let _ticker;

    //set contracts instances
    before(async function() {
        // Deploy tokens to testnet
        contractInstance = await myCryptoCats.new();
        console.log("CONTRACT ",contractInstance.address);
    });

    describe("ERC721", () => {

        it("will fail cuz ownerOf tokenId is invalid", async function (){
            await expectRevert(
                contractInstance.createKittyGen0("123456789"),
                "ERC721: owner query for nonexistent token"
            );
        });

    }); //end describe "ERC721"
}); //end contract "CryptoCats"