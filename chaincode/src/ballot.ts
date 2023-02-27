'use strict';
import {Contract, Context} from 'fabric-contract-api'
// import moment from 'moment';
import constant from './constant';
import { Constituency, Party, Candidate, VoterId, ElectionCommissionChief, ElectionTimeStamp, Vote} from './declarations'
import { createCompositeKey, getStateByKey } from './helper'
import {errors} from './errors'
export class Ballot extends Contract {
    async initLedger(ctx: Context) {
        console.log("===========INIT-LEDGER===========")
        const { params } = await ctx.stub.getFunctionAndParameters();
        //new Date(1995, 11, 17, 3, 24, 0);
        // electionStart and end time must be passed like this "DD-MM-YYYY HH:MM:SS"
        const [ chiefName, chiefAadharNumber, electionStartTimeStamp, electionEndTimeStamp] = params;
        const key = await createCompositeKey(ctx, [constant.ELECTION_COMMISSION_CHIEF])

        const electionCommissionChiefObject: ElectionCommissionChief = {
            name: chiefName,
            aadharNumber: chiefAadharNumber
        }
        await ctx.stub.putState(key, Buffer.from(JSON.stringify(electionCommissionChiefObject)))
        const electionTimeKey = await createCompositeKey(ctx, [constant.ELECTION_TIMESTAMP])
        const electionTimeObject: ElectionTimeStamp = {
            startTime: electionStartTimeStamp,
            endTime: electionEndTimeStamp
        }
        await ctx.stub.putState(electionTimeKey, Buffer.from(JSON.stringify(electionTimeObject)));
        await ctx.stub.putState(constant.ELECTION, Buffer.from(JSON.stringify({})));
        return JSON.stringify({
            status: "Ledger initiated, Added Election Commission Chief",
            data: {
                electionCommissionChiefObject,
                electionTimeObject,
            }
        })
    }
    async updateElectionCommissionChief(ctx: Context) {
        const { params } = ctx.stub.getFunctionAndParameters();
        const [ name, aadharNumber ] = params;
        const electionCommissionChiefObjectBytes = await ctx.stub.getState(constant.ELECTION_COMMISSION_CHIEF);
        const electionCommissionChiefObject: ElectionCommissionChief = JSON.parse(electionCommissionChiefObjectBytes.toString());
        electionCommissionChiefObject.name = name;
        electionCommissionChiefObject.aadharNumber = aadharNumber;
        await ctx.stub.putState(constant.ELECTION_COMMISSION_CHIEF, Buffer.from(JSON.stringify(electionCommissionChiefObject)));
        return JSON.stringify({
            status: "Updated Election Commission Chief",
            data: {
                electionCommissionChiefObject,
                old: JSON.parse(electionCommissionChiefObjectBytes.toString()),
                new: electionCommissionChiefObject
            }
        })
    }
    async registerConstituency(ctx: Context) {
        try {
            const { params } = await ctx.stub.getFunctionAndParameters();
            const [id, name, reserved, constituencyCode, state, stateCode, country] = params; 
            const key = await createCompositeKey(ctx, [constant.CONSTITUENCY, stateCode, constituencyCode, name]);
            const constinuency = await getStateByKey(ctx, key)
            if (constinuency !== null) {
                throw errors.CONSTITUENCY_ALREADY_EXIST
            }
            const constituencyObject: Constituency = {
                id, name, reserved, constituencyCode: constituencyCode, state, stateCode, country
            }
            await ctx.stub.putState(key, Buffer.from(JSON.stringify(constituencyObject)))
            return JSON.stringify({
                status: "Added New constituency",
                statusCode: 200,
                data: constituencyObject
            })
        } catch(error) {
            console.error('ERROR: ', error, { METHOD: 'registerConstituency', FILE: 'user' });
            if (typeof error === 'string' && Object.keys(errors).includes(error)) {
                throw new Error(error);
            } else {
                throw new Error('CHAINCODE_ERROR');
            }
        }
    }

    async registerParty(ctx: Context) {
        try {
            const { params } = await ctx.stub.getFunctionAndParameters();
            const [id, name, estDate, memebersCount, partyFlag, partyShortcut] = params;
            const key = await createCompositeKey(ctx, [constant.PARTY, partyShortcut, name]);
            const party = await getStateByKey(ctx, key);
            if (party !== null) {
                throw errors.PARTY_ALREADY_EXIST
            }
            const partyObject: Party = {
                id, name, 
                estDate: estDate, // date format MM-DD-YYYY
                memebersCount: parseFloat(memebersCount),
                partyFlag, partyShortcut
            }
            await ctx.stub.putState(key, Buffer.from(JSON.stringify(partyObject)))
            return JSON.stringify({
                status: "Added New Party",
                statusCode: 200,
                data: partyObject
            })
        } catch(error) {
            console.error('ERROR: ', error, { METHOD: 'registerParty', FILE: 'user' });
            if (typeof error === 'string' && Object.keys(errors).includes(error)) {
                throw new Error(error);
            } else {
                throw new Error('CHAINCODE_ERROR');
            }
        }
    }


    async registerVoterId(ctx: Context) {
        try {
            const { params } = await ctx.stub.getFunctionAndParameters();
            const [id, name, aadharNumber, age, dob, constituencyCode, constituencyName, address, 
                city, state, stateCode, country, isAlive, caste
            ] = params;
            const constinuencyKey = await createCompositeKey(ctx, [constant.CONSTITUENCY, stateCode, constituencyCode, name]);
            const constinuency = await getStateByKey(ctx, constinuencyKey);
            if (constinuency == null) {
                throw errors.CONSTITUENCY_NOT_EXIST
            }
            const key = await createCompositeKey(ctx, [constant.VOTER_ID, stateCode, constituencyCode, name, aadharNumber]);
            const voterId = await getStateByKey(ctx, key);
            if (voterId !== null) {
                throw errors.VOTERID_ALREADY_EXIST
            }
            const voterIdObject: VoterId = {
                id, name, aadharNumber, age: parseFloat(age), dob: dob,
                constituencyCode: constituencyCode, constituencyName,
                address, city, state, stateCode, country, isAlive: Boolean(isAlive), caste
            }
            await ctx.stub.putState(key, Buffer.from(JSON.stringify(voterIdObject)))
            return JSON.stringify({
                status: "Added New Voter Id",
                statusCode: 200,
                data: voterIdObject
            })
        } catch(error) {
            console.error('ERROR: ', error, { METHOD: 'registerVoterId', FILE: 'user' });
            if (typeof error === 'string' && Object.keys(errors).includes(error)) {
                throw new Error(error);
            } else {
                throw new Error('CHAINCODE_ERROR');
            }
        }
    }


    async registerCandidate(ctx: Context) {
        try {
            const { params } = await ctx.stub.getFunctionAndParameters();
            const [id, name, aadharNumber, voterId, constituencyCode, state, stateCode, partyShortcut, partyFlag, caste ] = params;
            const candidateObject: Candidate = {
                id, name, aadharNumber, voterId, constituencyCode: constituencyCode,
                partyShortcut, state, stateCode: parseInt(stateCode), caste, partyFlag
            }
            const constinuencyKey = await createCompositeKey(ctx, [constant.CONSTITUENCY, stateCode, constituencyCode, name]);
            const constinuency = await getStateByKey(ctx, constinuencyKey);
            if (constinuency == null) {
                throw errors.CONSTITUENCY_NOT_EXIST
            }
            const partyKey = await createCompositeKey(ctx, [constant.PARTY, partyShortcut, name]);
            const party = await getStateByKey(ctx, partyKey);
            if (party !== null) {
                throw errors.PARTY_ALREADY_EXIST
            }
            const key = await createCompositeKey(ctx, [constant.CANDIDATE, stateCode, constituencyCode, partyShortcut, aadharNumber, voterId]);
            const candidate = await getStateByKey(ctx, key);
            if (candidate !== null) {
                throw errors.CANDIDATE_ALREADY_EXIST
            }
            // if the candidate dont have any voter id
            const voterIdKey = await createCompositeKey(ctx, [constant.VOTER_ID, stateCode, constituencyCode, name, aadharNumber]);
            const voterIdData = await getStateByKey(ctx, voterIdKey);
            if (voterIdData == null) {
                throw errors.VOTERID_NOT_EXIST
            }
            await ctx.stub.putState(key, Buffer.from(JSON.stringify(candidateObject)))
            return JSON.stringify({
                status: "Added New Candidate",
                statusCode: 200,
                data: candidateObject
            })
        } catch(error) {
            console.error('ERROR: ', error, { METHOD: 'registerCandidate', FILE: 'user' });
            if (typeof error === 'string' && Object.keys(errors).includes(error)) {
                throw new Error(error);
            } else {
                throw new Error('CHAINCODE_ERROR');
            }
        }
    }

    async isElectionChief(ctx: Context) {
        const { params } = await ctx.stub.getFunctionAndParameters();
        const key = await createCompositeKey(ctx, [constant.ELECTION_COMMISSION_CHIEF])
        const resultBytes = await ctx.stub.getState(key);
        const result: ElectionCommissionChief = JSON.parse(resultBytes.toString());
        if (result.name === params[0] && result.aadharNumber === params[1]) {
            return JSON.stringify({
                status: "Is Election Chief",
                data: true
            })
        }
        return JSON.stringify({
            status: "Is Election Chief",
            data: false
        })
    }
    async getVotingStartTime(ctx: Context) {
        const key = await createCompositeKey(ctx, [constant.ELECTION_TIMESTAMP]);
        const resultBytes = await ctx.stub.getState(key);
        const result: ElectionTimeStamp = JSON.parse(resultBytes.toString());
        return JSON.stringify({
            status: "Voting Start Time",
            data: result.startTime
        })
    }
    async getVotingEndTime(ctx: Context) {
        const key = await createCompositeKey(ctx, [constant.ELECTION_TIMESTAMP]);
        const resultBytes = await ctx.stub.getState(key);
        const result: ElectionTimeStamp = JSON.parse(resultBytes.toString());
        return JSON.stringify({
            status: "Voting End Time",
            data: result.endTime
        })
    }
    async extendVotingTime(ctx: Context) {
        const { params } = await ctx.stub.getFunctionAndParameters();
        const startTime = params[0], endTime = params[1];
        const key = await createCompositeKey(ctx, [constant.ELECTION_TIMESTAMP]);
        const resultBytes = await ctx.stub.getState(key);
        const result: ElectionTimeStamp = JSON.parse(resultBytes.toString());
        result.endTime = endTime;
        result.startTime = startTime;
        await ctx.stub.putState(key, Buffer.from(JSON.stringify(result)));
        return JSON.stringify({
            status: "Voting Time Extended",
            data: result
        })
    }

    async updateVotingStartTime(ctx: Context) {
        const { params } = await ctx.stub.getFunctionAndParameters();
        const startTime = params[0]
        const key = await createCompositeKey(ctx, [constant.ELECTION_TIMESTAMP]);
        const resultBytes = await ctx.stub.getState(key);
        const result: ElectionTimeStamp = JSON.parse(resultBytes.toString());
        result.startTime = startTime;
        await ctx.stub.putState(key, Buffer.from(JSON.stringify(result)));
        return JSON.stringify({
            status: "Updating Election Start Time",
            data: result
        })
    }
    
    async updateVotingEndTime(ctx: Context) {
        const { params } = await ctx.stub.getFunctionAndParameters();
        const endTime = params[0]
        const key = await createCompositeKey(ctx, [constant.ELECTION_TIMESTAMP]);
        const resultBytes = await ctx.stub.getState(key);
        const result: ElectionTimeStamp = JSON.parse(resultBytes.toString());
        result.endTime = endTime;
        await ctx.stub.putState(key, Buffer.from(JSON.stringify(result)));
        return JSON.stringify({
            status: "Updating Election End Time",
            data: result
        })
    }
    async getCandidateList(ctx: Context) {
        const allCandidateIterator = await ctx.stub.getStateByPartialCompositeKey(constant.CANDIDATE, []);
        let res = []
        let allCandidateRange = await allCandidateIterator.next();
        while (!allCandidateRange.done) {
            if (!allCandidateRange || !allCandidateRange.value || !allCandidateRange.value.key) {
                break;
            }
            const key = await ctx.stub.splitCompositeKey(allCandidateRange.value.key);
            const candidateData = JSON.parse(allCandidateRange.value.value.toString());
            candidateData.key = key.attributes[1];
            res.push(candidateData);
            allCandidateRange = await allCandidateIterator.next();
        }
        
        return JSON.stringify({
            status: "List of Candidates",
            data: res
        })
    } 
    async getConstituencyList(ctx: Context) {
        const allConstituencyIterator = await ctx.stub.getStateByPartialCompositeKey(constant.CONSTITUENCY, []);
        let res = []
        let allConstituencyRange = await allConstituencyIterator.next();
        while (!allConstituencyRange.done) {
            if (!allConstituencyRange || !allConstituencyRange.value || !allConstituencyRange.value.key) {
                break;
            }
            const key = await ctx.stub.splitCompositeKey(allConstituencyRange.value.key);
            const candidateData = JSON.parse(allConstituencyRange.value.value.toString());
            candidateData.key = key;
            res.push(candidateData);
            allConstituencyRange = await allConstituencyIterator.next();
        }
        res = res.map(item => {
            const keys = Object.keys(item.key);
            const values = Object.values(item.key);
            return {
                ...item,
                keys: keys.toString(),
                values: values.toString()
            }
        })
        return JSON.stringify({
            status: "List of Constituency",
            data: res
        })
    }
    async getConstituency(ctx: Context, params: string[]) {
        const [stateCode, constituencyCode, ...rest] = params;        
        const allConstituencyIterator = await ctx.stub.getStateByPartialCompositeKey(constant.CONSTITUENCY, [stateCode, constituencyCode, ...rest]);
        let res = []
        let allConstituencyRange = await allConstituencyIterator.next();
        while (!allConstituencyRange.done) {
            if (!allConstituencyRange || !allConstituencyRange.value || !allConstituencyRange.value.key) {
                break;
            }
            const key = await ctx.stub.splitCompositeKey(allConstituencyRange.value.key);
            const candidateData = JSON.parse(allConstituencyRange.value.value.toString());
            candidateData.key = key;
            res.push(candidateData);
            allConstituencyRange = await allConstituencyIterator.next();
        }
        const [ constituency ] = res;
        return constituency ? constituency : null;
    }
    async getCandidate(ctx: Context, params: string[]) {
        const [stateCode, constituencyCode, partyShortcut, ...rest] = params
        const allCandidateIterator = await ctx.stub.getStateByPartialCompositeKey(constant.CANDIDATE, [stateCode, constituencyCode, partyShortcut, ...rest]);
        let res = []
        let allCandidateRange = await allCandidateIterator.next();
        while (!allCandidateRange.done) {
            if (!allCandidateRange || !allCandidateRange.value || !allCandidateRange.value.key) {
                break;
            }
            const key = await ctx.stub.splitCompositeKey(allCandidateRange.value.key);
            const candidateData = JSON.parse(allCandidateRange.value.value.toString());
            candidateData.key = key.attributes[1];
            res.push(candidateData);
            allCandidateRange = await allCandidateIterator.next();
        }
        const [ candidate ] = res;
        return candidate ? candidate : null; 
    }
    async getVoterId(ctx: Context, params: string[]) {
        const [stateCode, constituencyCode, name, voterId] = params;
        const allVoterIdIterator = await ctx.stub.getStateByPartialCompositeKey(constant.VOTER_ID, [stateCode, constituencyCode, name]);
        let res = null;
        let allVoterIdRange = await allVoterIdIterator.next();
        while (!allVoterIdRange.done) {
            if (!allVoterIdRange || !allVoterIdRange.value || !allVoterIdRange.value.key) {
                break;
            }
            const key = await ctx.stub.splitCompositeKey(allVoterIdRange.value.key);
            const candidateData = JSON.parse(allVoterIdRange.value.value.toString());
            candidateData.key = key.attributes[1];
            if (candidateData.id === voterId) {
                res = candidateData;
            }
            allVoterIdRange = await allVoterIdIterator.next();
        }
        return res ? res : null;
    }
    
    async vote(ctx: Context) {
        const { params } = await ctx.stub.getFunctionAndParameters();
        const [voterId, candidateId, constituencyCode, stateCode, partyShortcut] = params;
        const candidate: Candidate = await this.getCandidate(ctx, [stateCode, constituencyCode, partyShortcut]);
        const constituency: Constituency = await this.getConstituency(ctx, [stateCode, constituencyCode])
        if (candidate == null) {
            throw errors.CONSTITUENCY_NOT_EXIST
        }
        if (candidate == null) {
            throw errors.CANDIDATE_NOT_EXIST
        }
        const voterIdData = await this.getVoterId(ctx, [stateCode, constituencyCode, constituency.name, voterId])
        if (voterIdData == null) {
            throw errors.VOTERID_NOT_EXIST
        }
        const txId = await ctx.stub.getTxID();

        const key = await createCompositeKey(ctx, [constant.VOTE, stateCode, constituencyCode, partyShortcut, candidateId, txId])

        const voteObject: Vote = {
            voterId: voterId,
            candidateId: candidateId,
            partyShortcut: partyShortcut,
            constituencyCode: constituencyCode,
            stateCode: stateCode,
            candidate,
            constituency
        }
        await ctx.stub.putState(key, Buffer.from(JSON.stringify(voteObject)));
        return {
            status: 'New Vote Added',
        }
    }
    async results(ctx: Context) {
        const allResultsIterator = await ctx.stub.getStateByPartialCompositeKey(constant.VOTE, []);
        let res = []
        let allResultsRange = await allResultsIterator.next();
        while (!allResultsRange.done) {
            if (!allResultsRange || !allResultsRange.value || !allResultsRange.value.key) {
                break;
            }
            const key = await ctx.stub.splitCompositeKey(allResultsRange.value.key);
            const candidateData = JSON.parse(allResultsRange.value.value.toString());
            candidateData.key = key;
            res.push(candidateData);
            allResultsRange = await allResultsIterator.next();
        }
        const resultsByConstituency: any = {}
        for (let i = 0; i < res.length; i++) {
            const item: Vote = res[i];
            const candidate: Candidate = item.candidate;
            const constinuency: Constituency = item.constituency;
            if (item.constituencyCode in resultsByConstituency) {
                const vote = resultsByConstituency[item.constituencyCode];
                const candidateAndParty = `${item.partyShortcut}_${item.candidateId}`
                if (candidateAndParty in vote) {
                    vote[candidateAndParty].vote++;
                } else {
                    vote[`${item.partyShortcut}_${item.candidateId}`] = {
                        vote: 1,
                        candidateName: candidate.name
                    }
                }
            } else {
                resultsByConstituency[item.constituencyCode] = {
                    constituencyCode: item.constituencyCode,
                    stateCode: item.stateCode,
                    [`${item.partyShortcut}_${item.candidateId}`]: {
                        vote: 1,
                        candidateName: candidate.name
                    },
                    state: constinuency.state,
                    constinuencyName: constinuency.name,
                }
            }
        }
        return JSON.stringify({
            status: "results by constituency",
            data: resultsByConstituency
        })
    }
}




// status: string, data : Object

// General election voting 

/*
    election commision // supreme org

    party wise org
        congress
        bjp
        aap
        CPIM

EC = election commission

process - 1 (EC and parties)
step - 1 the election commission will give the list of constituency
step - 2 EC will the dead line to register candidates 
step - 3 candidates will registerd for each constituency by diffrent party, can be updated (only before deadline provided by the EC)
        note: candidate must be citizen of india, age >= 25, crimal record < 2 case, jail-time < 2 years
step - 4 manifesto will be submitted by each party and updated before the deadline   

party org permission
    1 -  cant vote from party peers
    2 -  cant update party members and manifesto after the deadline
    
    
process - 2 (EC and people)
    note: no separte org for people
    1 - people can register and recive voter id (uniq id)
        -> must be the citized of india && age >= 18
        -> no uplicate entry, must have aadher to get voter id
    2 - deadline for voter registeration


methods 

    isElectionChief() -> To check if the user is Election Chief(admin of EC or supreme org) or not 
    isEligibleVote() -> To check if the vote is eligible
    getResults() -> based upon the votes, declare results for each candidate, constituency, and party
    extendVotingTime() -> To extend the end of the voting
    updateVotingStartTime() -> used to update the voting start times
    updateVotingEndTime() ->  used to update the voting  end times
    getVotingEndTime() -> Gives ending time of voting
    getVotingStartTime() -> Gives starting time of voting
    vote() -> Give your vote to candidate.
    isVoterEligible() -> To check voter is eligible
    getCandidateList() ->  Get candidate list. 
    didCurrentVoterVoted() ->  Know whether the voter casted their vote or not. If casted get candidate object.
    registerConstituency()
    registerCandidate()
    registerVoterId()
*/

/*
    depend upon the constituency we will show the candidates list

    voter with id can vote any one from the constituency 
*/

/**
 party -> 
    candidates, party
    electionComission
    start end
    ballot 
    {
        c1: {
            INC_Name: 1
            BJP_NAme: 2
        }
        c2: {

        }
    }
    voterId: register
    general: {
        2014: {}
        2019: {}
        2024: {}
    }
 */

    /**
     * 
     * 
     * 
     *  ECI -> 1st page, voter id, approve, constinuency
     *  party: 
     *         registerParty,
     *          candidates,
     *          GetResults()
     *                  -> by party
     *                  -> by state, 
     *                  -> by state and by party,
     *                  -> 
     *  
     */


