module.exports =(db) => {
  const ethJsUtil = require('ethereumjs-util');
  const offlinetx = require("../crypto/offlinetx")(db);
  const cache = require('../cache/txHelper.js')(db);

return {

  getEligibleVoter: async function(voter) {
    let voterData = await db.electionInstance.methods.eligibleVoters(voter).call();
    return {"eligible":voterData[0], "blindedVote": voterData[1],"blindlySignedVote":voterData[2]};
  },

    getBlindedVotes: async function(blindedVotes) {
      console.log("dasdas");
        let blindedVotesData = await db.electionInstance.methods.blindedVotes(blindedVotes).call();
        return {"address":blindedVotesData};
    },

    getVotes: async function(votes) {
        let votesData = await db.electionInstance.methods.votes(votes).call();
        return {"votes":votesData};
    },


  postEligibleVoter: async function(voter) {

      let txHash= db.electionInstance.methods.addEligibleVoter(voter).send({from:db.accounts[0]});
  /*    let tx = db.electionInstance.methods.addEligibleVoter(voter);
      let rawTx = await offlinetx.getTxJson(tx, {from: db.accounts[0], gasPrice: "0x00"});

      cacheValues = await cache.writeUnsentTxToCache(rawTx);
      cache.setCache(cacheValues[0], JSON.stringify(cacheValues[1]));
  */
      return txHash;
  },


  deleteEligibleVoter: async function(voter) {
      let tx = db.electionInstance.methods.addEligibleVoter(voter);
      let rawTx = await offlinetx.getTxJson(tx, {from: db.accounts[0], gasPrice: "0x00"});

      cacheValues = await cache.writeUnsentTxToCache(rawTx);
      cache.setCache(cacheValues[0], JSON.stringify(cacheValues[1]));

      return rawTx;
  },


  castVote: async function(choiceCode, vote, hashVote, blindlySingedVote) {
      //@TODO untested
      let tx = db.electionInstance.methods.Vote(choiceCode, vote, hashVote, blindlySingedVote);
      let rawTx = await offlinetx.getTxJson(tx, {from: db.accounts[0], gasPrice: "0x00"});

      cacheValues = await cache.writeUnsentTxToCache(rawTx);
      cache.setCache(cacheValues[0], JSON.stringify(cacheValues[1]));

      return rawTx;
  },

    postRequestBlindSig: async function(blindedVote) {
        //@TODO untested
        let tx = db.electionInstance.methods.requestBlindSig(blindedVote);
        let rawTx = await offlinetx.getTxJson(tx, {from: db.accounts[0], gasPrice: "0x00"});
        cacheValues = await cache.writeUnsentTxToCache(rawTx);
        cache.setCache(cacheValues[0], JSON.stringify(cacheValues[1]));

        return rawTx;
    },

    postWriteBlindSig: async function(voter, blindSig) {
        //@TODO untested
        let tx = db.electionInstance.methods.writeBlindSig(voter, blindSig);
        let rawTx = await offlinetx.getTxJson(tx, {from: db.accounts[0], gasPrice: "0x00"});
        cacheValues = await cache.writeUnsentTxToCache(rawTx);
        cache.setCache(cacheValues[0], JSON.stringify(cacheValues[1]));

        return rawTx;
    },

    postVerifyBlindSig: async function(voter, blindSig) {
        //@TODO untested
        let tx = db.electionInstance.methods.verifyBlindSig(voter, blindSig);
        let rawTx = await offlinetx.getTxJson(tx, {from: db.accounts[0], gasPrice: "0x00"});
        cacheValues = await cache.writeUnsentTxToCache(rawTx);
        cache.setCache(cacheValues[0], JSON.stringify(cacheValues[1]));

        return rawTx;
    },

}};
