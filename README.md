# A blind-signature-based e-voting platform on Ethereum

**Note:** this is a proof-of-concept implementation of [this paper](https://eprint.iacr.org/2017/1043.pdf). You can find the accompanying Medium article [here](https://medium.com/coinmonks/implementing-an-e-voting-protocol-with-blind-signatures-on-ethereum-411e88af044a).

## Motivation
Previously proposed voting protocols for Ethereum were neither efficient nor provided secret ballots. If you look at the official Ethereum website it suggests voting as one of the potential areas where (public) blockchains might successfully be applied. They also propose a toy example [here](https://www.ethereum.org/dao). However it is not able to provide secret ballots, meaning that anyone is able to see how others voted. This is clearly unwanted in most applications. 

A more elaborated protocol is the Open Vote Network protocol ([OVN](http://homepages.cs.ncl.ac.uk/feng.hao/files/OpenVote_IET.pdf)) created by Feng Hao et al. and implemented by Patrick McCorry [here](https://eprint.iacr.org/2017/110). It is able to provide secret ballots, however it is not gas-efficient, meaning that the cost of casting a ballot is linearly increases with the number of participants. Unfortunately this property limits the number of participants in a single election to cca. 20-30 voters.

To fix these issues, [János Gulácsy](https://github.com/donfrigo) and me decided to implement a blind-signature-based e-voting protocol for Ethereum. This provides secret-ballots, while casting a ballot remains at a constant gas cost (~200k gas (unoptimized)). 

## Reminder
This is only a Proof-of-concept work. Eventhough we did our best, most likely it contains critical bugs.

Moreover just like any other blockchain-based e-voting scheme, this scheme is also coercion-irresistance. An attacker could easily bribe voters to vote for a specific candidate. Even worse voters can trustlessly prove this to the attacker to collect their financial reward. For more details, please check [this amazing blogpost](http://hackingdistributed.com/2018/07/02/on-chain-vote-buying/) out by Phil Daian.

Therefore only use this code to non-mission-critical elections.

## Contributing and contact       
**PRs, issues are welcome. You can reach me out on [Twitter](https://twitter.com/Istvan_A_Seres) or [ethresear.ch](https://ethresear.ch/u/seresistvan).**
