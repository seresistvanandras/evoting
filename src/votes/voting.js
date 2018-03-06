module.exports =(db) => {
  const ethJsUtil = require('ethereumjs-util');

return {

  getEligibleVoter: async function(voter) {
    //TODO
    db.electionInstance.eligibleVoters.methods.call(voter);
  },


  postEligibleVoter: async function(voter) {
    //TODO
  },


  deleteEligibleVoter: async function(voter) {
    //TODO
  },


  castVote: async function(choiceCode, vote, hashVote, blindlySingedVote) {
    //TODO
  },
}};
