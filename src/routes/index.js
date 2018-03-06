const votingRoutes = require('./voting_routes.js');


module.exports = function(server, env) {

  server.use(function(req, res, next) {
    res.header("Access-Control-Allow-Origin", "*");
    res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
    next();
  });

  votingRoutes(server, env);
};
