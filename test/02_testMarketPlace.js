const TheSlimeRoad   = artifacts.require('./TheSlimeRoad.sol')

const EscargotsArtifact = require('./../build/contracts/Escargots.json');

let tryCatch = require("./exceptions.js").tryCatch;

let errTypes = require("./exceptions.js").errTypes;



contract('Market ', function (accounts) {

    // Setup before each test
    beforeEach('setup contract for each test', async function () {
        // Deploying contracts

        var Escargots = contract(EscargotsArtifact);
        Escargots.setProvider(window.web3.currentProvider);


        TheSlimeRoadInstance = await TheSlimeRoad.new({from: accounts[0]})
        escargotsInstance = await Escargots.new({from: accounts[0]})
        TheSlimeRoadInstance.setEscargotAddress(escargotsInstance)
        //await escargotsInstance._mint(accounts[0], 0, {from: accounts[0]}); 
        //await escargotsInstance._mint(accounts[0], 1, {from: accounts[0]}); 
    
    })

    it('selling token', async function (){

    // deposit 2 tokens to sell
            await TheSlimeRoadInstance.deposit(0, 10, {from: accounts[0]})
            await TheSlimeRoadInstance.deposit(1, 10, {from: accounts[0]})

    })

    it('cancelling a sell ', async function (){

            await TheSlimeRoadInstance.cancelSale(1, {from: accounts[0]})
    
    })

    it('buying a token', async function (){

            await TheSlimeRoadInstance.buy(0, {from: accounts[1], value: 10})
    })
    
    it('put to auction', async function (){

        await TheSlimeRoadInstance.putAuction(1, 10, {from: accounts[0]})
    })

    it('bid on auction', async function (){

        await TheSlimeRoadInstance.bid(0, {from: accounts[1], value:11})
    })

    it('cashout', async function (){

        await TheSlimeRoadInstance.cashout(0, {from: accounts[0]})
    })


})