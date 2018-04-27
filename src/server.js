const Express = require('express');
const url = require("url");
const BodyParser = require('body-parser')

const Web3 = require('web3');
const net = require('net');


let App = {

    web3: {},
    web3Provider: {},
    web3ProviderClass: {},

    ChainId: {},

    server: {},
    port: {},


    init: function() {
        App.server = Express();

        App.initWeb3().then( () => {
            App.port = 8001;
        App.startServing();
    });
    },

    initWeb3: async function() {
        let url = "http://localhost:8545";
        let protocol = url.split(":")[0];

        switch (protocol) {
            case "http":
                App.web3ProviderClass = Web3.providers.HttpProvider;
                break;
            case "ws":
                App.web3ProviderClass = Web3.providers.WebsocketProvider;
                break;
            default:
                App.web3ProviderClass = Web3.providers.IpcProvider;
        }

        App.web3Provider = new App.web3ProviderClass(url, net);
        App.web3 = new Web3(App.web3Provider);

        let electionContractJson = require("../build/contracts/ElectionECCwPrecompile.json");

        App.ElectionABI =  electionContractJson.abi;
        App.ElectionBIN = electionContractJson.bytecode;


        App.ChainId = await App.web3.eth.net.getId();
        let electionAddr = electionContractJson.networks[App.ChainId].address;


        App.ElectionInstance = new App.web3.eth.Contract(
            App.ElectionABI,
            electionAddr
        );
    },

    startServing: async function() {
        App.server.use(BodyParser.json());


        await App.web3.eth.getAccounts().then(function(e){
            App.accounts = e;
        });
        console.log(App.accounts);

        require('./routes')(App.server, {
            web3: App.web3,
            accounts: App.accounts,
            electionAddr: App.ElectionInstance._address,
            electionABI: App.ElectionABI,
            electionInstance: App.ElectionInstance
        });



        App.server.listen(App.port, () => {
            console.log('We are live on ' + App.port);

        console.log("Deployed Election contract address: ", App.ElectionInstance._address);
        App.ElectionInstance.methods.owner().call().then( function(owner) {
            console.log("Election owner: "+owner);
        });
    });
    },
    /*
      testRpcHack: function(contract) {
        if (typeof contract.currentProvider.sendAsync !== "function") {
          contract.currentProvider.sendAsync = function() {
            return contract.currentProvider.send.apply(
              contract.currentProvider,
              arguments
            );
          };
        }
      },
    */
};

App.init();
