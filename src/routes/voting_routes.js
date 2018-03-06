module.exports = function(server, env) {
  const election = require('../votes/voting.js')(env);

  //get data from EligibleVoter Mapping
  server.get(
    '/vote/:voter',
    (req, res) => {
      let model = election.getEligibleVoter(
        req.params.voter
      );
      model.then( m => { res.send(JSON.stringify(m)); } );
    }
  );

  //invite voter from EligibleVoter Mapping
  server.post(
    '/vote/:voter',
    (req, res) => {
      let model = election.postEligibleVoter(
        req.params.voter
      );
      model.then( m => {
        res.send(JSON.stringify(m));
      } );
    }
  );

  //remove voter from EligibleVoter Mapping
  server.delete(
    '/vote/:voter',
    (req, res) => {
      let model = election.deleteEligibleVoter(
        req.params.member
      );
      model.then( m => { res.send(JSON.stringify(m)); } );
    }
  );

  // cast a vote from a newly generated Address
  server.post(
    '/vote/cast/',
    (req, res) => {
      let model = election.castVote(
        req.body.choiceCode,
        req.body.vote,
        req.body.hashVote,
        req.body.blindlySignedVote
      );
      model.then( m => { res.send(JSON.stringify(m)); } );
    }
  );

};
