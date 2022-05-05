//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import '@chainlink/contracts/src/v0.8/ChainlinkClient.sol';

/**
 * Request testnet LINK and ETH here: https://faucets.chain.link/
 * Find information on LINK Token Contracts and get the latest ETH and LINK faucets here: https://docs.chain.link/docs/link-token-contracts/
 */

/**
 * @notice DO NOT USE THIS CODE IN PRODUCTION. This is an example contract.
 */
contract APElection is ChainlinkClient {
    using Chainlink for Chainlink.Request;

    uint256 public voteCount;
    bytes32 public firstName;
    bytes32 public lastName;
    bytes32 public candidateId;
    bytes32 public party;
    bytes[] public candidates;

    address private oracle;
    bytes32 private jobId;
    uint256 private fee;

    event WinnerFound(bytes32 firstName, bytes32 lastName, uint256 voteCount, bytes32 candidateId, bytes32 party);

    /**
     * Network: Kovan
     * Oracle:
     *      Name:           Chainlink DevRel - Kovan
     *      Address:        0xf4316Eb1584B3CF547E091Acd7003c116E07577b
     * Job:
     *      Name:           AP Election Data
     *      ID:             2e37b8362f474fce9dd019fa195a8627
     *      Fee:            0.1 LINK
     */
    constructor() {
        setChainlinkToken(0xa36085F69e2889c224210F603D836748e7dC0088);
        setChainlinkOracle(0xf4316Eb1584B3CF547E091Acd7003c116E07577b);
        jobId = '2e37b8362f474fce9dd019fa195a8627';
        fee = (1 * LINK_DIVISIBILITY) / 10; // 0,1 * 10**18 (Varies by network and job)
    }

    /**
     * Initial request
     */
    function requestElectionWinner() public returns (bytes32 requestId) {
        Chainlink.Request memory req = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);
        req.add('date', '2020-11-08');
        req.add('raceId', '0');
        req.add('statePostal', 'US');
        req.add('resultsType', 'l'); // Replace with l for live results.
        return sendChainlinkRequest(req, fee);
    }

    /**
     * Callback function
     */
    function fulfill(
        bytes32 _requestId,
        uint256 _voteCount,
        bytes32 _firstName,
        bytes32 _lastName,
        bytes32 _candidateId,
        bytes32 _party,
        bytes[] memory _candidates
    ) public recordChainlinkFulfillment(_requestId) {
        voteCount = _voteCount;
        firstName = _firstName;
        lastName = _lastName;
        candidateId = _candidateId;
        party = _party;
        candidates = _candidates;
        emit WinnerFound(firstName, lastName, voteCount, candidateId, party);
    }

    function getCandidate(uint256 _idx)
        external
        view
        returns (
            uint32,
            string memory,
            string memory,
            string memory,
            uint32,
            bool
        )
    {
        (
            uint32 decodedId,
            string memory decodedParty,
            string memory decodedFirstName,
            string memory decodedLastName,
            uint32 decodedVoteCount,
            bool decodedIsWinner
        ) = abi.decode(candidates[_idx], (uint32, string, string, string, uint32, bool));
        return (decodedId, decodedParty, decodedFirstName, decodedLastName, decodedVoteCount, decodedIsWinner);
    }

    // function withdrawLink() external {} - Implement a withdraw function to avoid locking your LINK in the contract
}
