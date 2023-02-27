
export type VoterId = {
    id: string,
    name: string,
    aadharNumber: string,
    age: number,
    dob: string,
    constituencyCode: string,
    constituencyName: string,
    address: string,
    city: string,
    state: string,
    stateCode: string,
    country: string,
    isAlive: boolean,
    caste: string,
}

export type Constituency = {
    id: string,
    name: string,
    reserved: string,
    state: string,
    constituencyCode: string,
    stateCode: string,
    country: string,
}
export type Party = {
    id: string,
    name: string,
    estDate: string,
    memebersCount: number,
    partyFlag: string, 
    partyShortcut: string;
}
export type Candidate = {
    id: string,
    name: string,
    aadharNumber: string,
    voterId: string, // one to one relation with VoterId.id
    constituencyCode: string
    stateCode: number,
    state: string,
    partyShortcut: string,
    partyFlag: string,
    caste: string,
}


export type ElectionCommissionChief = {
    name: string,
    aadharNumber: string,
}

export type ElectionTimeStamp = {
    startTime: string,
    endTime: string,
}

export type Vote = {
    voterId: string,
    candidateId: string,
    partyShortcut: string,
    constituencyCode: string,
    stateCode: string,
    candidate: Candidate,
    constituency: Constituency,
}

export type Results = {
    constituencyCode: string,
    stateCode: string,

}

export type RequiredType = {
    [key: string]: string[]
}