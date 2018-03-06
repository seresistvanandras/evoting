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
      let tx = db.electionInstance.methods.removeEligibleVoter(voter);
      let rawTx = await offlinetx.getTxJson(tx, {from: db.accounts[0], gasPrice: "0x00"});

      cacheValues = await cache.writeUnsentTxToCache(rawTx);
      cache.setCache(cacheValues[0], JSON.stringify(cacheValues[1]));

      return rawTx;
  },


  castVote: async function(choiceCode, vote, hashVote, blindlySingedVote) {
        console.log(choiceCode, vote, hashVote, blindlySingedVote);
      let txHash = db.electionInstance.methods.Vote(choiceCode, vote, hashVote, blindlySingedVote).send({from: db.accounts[0]});

      return txHash;
  },

    postRequestBlindSig: async function(blindedVote) {
        let tx = db.electionInstance.methods.requestBlindSig(blindedVote);
        let rawTx = await offlinetx.getTxJson(tx, {from: db.accounts[0], gasPrice: "0x00"});
        cacheValues = await cache.writeUnsentTxToCache(rawTx);
        cache.setCache(cacheValues[0], JSON.stringify(cacheValues[1]));

        return rawTx;
    },

    postWriteBlindSig: async function(voter, blindSig) {
        let tx = db.electionInstance.methods.writeBlindSig(voter, blindSig);
        let rawTx = await offlinetx.getTxJson(tx, {from: db.accounts[0], gasPrice: "0x00"});
        cacheValues = await cache.writeUnsentTxToCache(rawTx);
        cache.setCache(cacheValues[0], JSON.stringify(cacheValues[1]));

        return rawTx;
    },

    postVerifyBlindSig: async function(vote, blindSig) {
        //@TODO under testing
        console.log(vote,blindSig);
        let txHash = db.electionInstance.methods.verifyBlindSig(vote,blindSig).send({from: db.accounts[0]});

        return txHash;
    },

}};
