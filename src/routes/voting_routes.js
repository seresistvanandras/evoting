module.exports = function(server, env) {
  const election = require('../votes/voting.js')(env);

  // get data from EligibleVoter Mapping
  server.get(
    '/vote/:voter',
    (req, res) => {
      let model = election.getEligibleVoter(
        req.params.voter
      );
      model.then( m => { res.send(JSON.stringify(m)); } );
    }
  );

    // get data from blindedVotes Mapping
    server.get(
        '/bvotes/:blindedVotes',
        (req, res) => {
        let model = election.getBlindedVotes(
            req.params.blindedVotes
        );
    model.then( m => { res.send(JSON.stringify(m)); } );
    }
    );

    // get data from votes Mapping
    server.get(
        '/votes/:votes',
        (req, res) => {
        let model = election.getVotes(
            req.params.votes
        );
    model.then( m => { res.send(JSON.stringify(m)); } );
    }
    );

  // invite voter from EligibleVoter Mapping
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

  // remove voter from EligibleVoter Mapping
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
    '/cast/',
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

    // Requires authority to blindly sign
    server.post(
        '/bvotes/req/',
        (req, res) => {
        let model = election.postRequestBlindSig(
            req.body.blindedVote
        );
    model.then( m => { res.send(JSON.stringify(m)); } );
    }
    );

    server.post(
        '/bvotes/write/',
        (req, res) => {
        let model = election.postWriteBlindSig(
            req.body.voter,
            req.body.blindSig
        );
    model.then( m => { res.send(JSON.stringify(m)); } );
    }
    );

    server.post(
        '/bvotes/verify/',
        (req, res) => {
        let model = election.postVerifyBlindSig(
            req.body.vote,
            req.body.blindlySignedVote
        );
    model.then( m => { res.send(JSON.stringify(m)); } );
    }
    );

};
