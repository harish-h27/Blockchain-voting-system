import { invokeTransaction } from "./invoke";
import {enrollUser, registerAndEnrollUser} from './enrollUser'
import { v4 as uuid } from "uuid";
import { constituency, parties, voters, candidates, votes } from "./data";
import { writeFileSync } from "fs";
import path from "path";

async function registerAll() {
  //registerConstituency
  for (let i = 0; i < constituency.length; i++) {
    let item = constituency[i];
    const params = [
      "registerConstituency",
      uuid(),
      item.name,
      item.reserved,
      item.constituencyCode,
      item.state,
      item.stateCode,
      item.country,
    ];
    const result = await invokeTransaction("ordererAdmin", params);
    console.log("registerConstituency: ", result);
  }

  //registerParty
  for (let i = 0; i < parties.length; i++) {
    let item = parties[i];
    const params = [
      "registerParty",
      item.id,
      item.name,
      item.estDate,
      item.memebersCount,
      item.partyFlag,
      item.partyShortcut,
    ];
    const result = await invokeTransaction("ordererAdmin", params);
    console.log("registerParty: ", result);
  }

  // registerVoterId
  for (let i = 0; i < voters.length; i++) {
    let item = voters[i];
    const params = [
      "registerVoterId",
      item.id,
      item.name,
      item.aadharNumber,
      item.age,
      item.dob,
      item.constituencyCode,
      "AK",
      item.address,
      item.city,
      item.state,
      item.stateCode,
      item.country,
      item.isAlive,
      item.caste,
    ];
    const result = await invokeTransaction("ordererAdmin", params);
    console.log("registerVoterId: ", result);
  }
  // registerCandidate
  for (let i = 0; i < candidates.length; i++) {
    let item = candidates[i];
    const params = [
      "registerCandidate",
      item.id,
      item.name,
      item.aadharNumber,
      item.voterId,
      item.constituencyCode,
      item.state,
      item.stateCode,
      item.partyShortcut,
      item.partyFlag,
      item.caste,
    ];
    const result = await invokeTransaction("ordererAdmin", params);
    console.log("registerCandidate: ", result);
  }
}

async function getAll() {
  let params = ["getConstituencyList"];
  let result = await invokeTransaction("ordererAdmin", params);
  writeFileSync(path.join(__dirname, "../","../", "results", "constituency_list.json"), JSON.stringify(result));



  const params1 = ["getCandidateList"];
  const result2 = await invokeTransaction("ordererAdmin", params1);
  writeFileSync(path.join(__dirname, "../","../", "results", "candidate_list.json"), JSON.stringify(result2));

}

async function voting() {
  // const [voterId, candidateId, constituencyCode, stateCode, partyShortcut] = params;

  for (let i = 0; i < votes.length; i++) {
    const item = votes[i];
    const params = [
      "vote",
      item.voterId,
      item.candidateId,
      item.constituencyCode,
      item.stateCode,
      item.partyShortcut,
    ];
    const result = await invokeTransaction("ordererAdmin", params);
    console.log("vote: ", result);
  }
}

async function results() {
  const finalResults = [];
  const params = ["results"];
  const result = await invokeTransaction("ordererAdmin", params);
  finalResults.push(result);
  writeFileSync(path.join(__dirname, "../","../", "results", "results.json"), JSON.stringify(finalResults));
}

async function run() {
  await enrollUser('ordererAdmin', 'ordererAdminpw');
  await enrollUser('admin', 'adminpw');
  await registerAndEnrollUser("harishbx", "harishpw");
  await registerAll();
  await getAll();
  await voting();
  await results();
}

run();
