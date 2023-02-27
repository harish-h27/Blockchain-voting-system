

# Blockchain based voting system using Hyperledger Fabric

### Introduction
- Online voting is a trend that is gaining momentum and trend in modern society. It has great potential to decrease organisational costs and increase voter turnout.
- It eliminates the need to print ballot papers or open polling stations—voters can vote from wherever there is an Internet connection. Despite these benefits, online voting solutions are viewed with a great deal of caution because they introduce new threats. A single vulnerability can lead to large-scale manipulations of votes. 
- Electronic voting systems must be legitimate, accurate, safe, and convenient when used for elections.
- For our blockchain we have used one of the most popualar framework for residing with our custom built blockchain, Hyperledger Fabric. Hyperledger Fabric allows to build architectural based application that has the use case of a private blockchain. Pak Voting System is one of the best use cases for using private blockchain.

### prerequisites
- Hyperledger Fabric Binary Version 2.2.9 And Fabric CA Server Version 1.5.5
```sh
    curl -sSL https://bit.ly/2ysbOFE | bash -s -- 2.2.9 1.5.5
```
- Node.js Version >= 14.20.1
- Docker - v1.12 or higher
- Docker Compose - v1.8 or higher
- Git client - needed for clone commands



### User Flow
- This network contains one main organization **Election Commission** and **MY Party** organization an example of political party 
- Election Commission organization is capable of adding new parties to the network
- Election Commission issues new voter id's to voters and registers constituency
- Election Commission decides voting time and date
- The parties can add their candidates to the constituency they can update it as well
- The results will be declared by Election Commission


### Folder structure
- **app/**  contains node.js application that communites with blockchain network and fabric ca server
- **chaincode/** contains smart contract or chaincode written in typescript
- **network/** contains blockchain network configuration, docker compose files and sh files to generate crypto materials and artifacts


### Instructions to running it locally

- cd to network folder
- execute run.sh file, wait for few minutes you will see all the logs in the command line
```sh
    ./run.sh
```

### output

- cd to results folder in the repo, you will see three files 
    - **candidate_list.json** -> list of all candidates
    - **constituency_list.json** -> list of all constituency 
    - **results.json** -> final results of election

## Contact:
Harish H
Email: harish-h@outlook.com
LinkedIn: [Harish H](https://www.linkedin.com/in/harish-h-0807561b3/)
Twitter: [im_harish.h](https://www.instagram.com/im_harish.h/)
