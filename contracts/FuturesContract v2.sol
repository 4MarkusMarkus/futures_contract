pragma solidity ^0.4.0;

//INPUT PARAMETERS: 6000, 1533686400, 1500000000000000000
//ROPSTEN TEST: 0x58a86ded501db24edacc280845e062431b7df79c

contract FuturesContract {

    uint public neutralExRate;
    uint public matirityTime;
    uint public collateral;
    uint public collateralOfOwner;
    uint public collateralOfTaker;
    bool public longORshort // this variable should be assigned to owner and taker at the contract creation, how best to do it? mapping? it's binary variable owner declares himself to be either "short" or "long" and taker has to take the other side of the trade
    address owner;
    address taker;

    
        enum Phase { Created, Waiting, Live}

    Phase public currentPhase = Phase.Created; // why is it "public" isn't this problematic? in the code would not it be good to set it in the constructer? is it possible? 
    event LogPhaseSwitch(Phase phase); // whats the purpose of this? 
    

    function FuturesContract(uint _neutralExRate, uint _matirityTime, uint _collateral, bool _longORshort){
        owner = msg.sender;
        neutralExRate = _neutralExRate;
        matirityTime = _matirityTime;
        collateral = _collateral;
        longORshort = _longORshort;
    }



    //fallback function can be used to send collateral -> what is the advantage of callback function calling fundingColateral function? isn't it better for the fundingColateral to be fallback function?
    function () payable {
        fundingColateral(msg.sender);
    }

    function fundingColateral(address _funder) public payable { // does "public" needs to be here?
        require(_funder != address(0)); //                              what does this mean?
        require(validFunding());  // validFunding returns  returns only "true" or "false" ? 
        if (_funder == owner) {
            require(currentPhase == Phase.Created);
            collateralOfOwner += msg.value;
            setSalePhase(Phase.Waiting);
        } else {
            require(currentPhase == Phase.Waiting);
            require(msg.value >= collateral);
            taker = _funder;
            collateralOfTaker += msg.value;
            setSalePhase(Phase.Live);
        }
    }

    function getPrice(uint time, uint oracleSignature, address interestedParty ) public {
        //TODO: Oracles, logic and other shit
    }

    function getBalance() public constant returns(uint256) {
        return this.balance;
    }

    function getCreator() public constant returns(address) {
        return owner;
    }

    function getTaker() public constant returns(address) {
        return taker;
    }

    function validFunding() internal view returns (bool) { // what does "view" do?
        bool withinPeriod = now <= matirityTime;
        bool nonZeroPurchase = msg.value > 0; //                  is this necessary?
        bool aboveLimit = msg.value >= collateral;

        return withinPeriod && nonZeroPurchase && aboveLimit; //        how does the return look? only true / false OR  true && true && true ...
    }

    function setSalePhase(Phase _nextPhase) internal {
        bool canSwitchPhase
        =  (currentPhase == Phase.Created && _nextPhase == Phase.Waiting)
        || (currentPhase == Phase.Waiting && _nextPhase == Phase.Live);

        require(canSwitchPhase);
        currentPhase = _nextPhase;
        LogPhaseSwitch(_nextPhase); // isn't this better? -> LogPhaseSwitch(currentPhase);
    }

    // Constant functions
    function getCurrentPhase() public view returns (string CurrentPhase) {
        if (currentPhase == Phase.Created) {
            return "Created";
        } else if (currentPhase == Phase.Waiting) {
            return "Waiting";
        } else if (currentPhase == Phase.Live) {
            return "Live";
        }
        
        
    }
    
    function liquidateByMe(unit liquidationExRate) internal view returns (bool) {       // liquidationPrice can be set internaly by getPrice function if conditions are met
       profit = (liquidationExRate - neutralExRate)
       if (profit >= 0) {
           FuturesContract.send(profit); // ! need to specify send to long seller | this is probably wrong - how to best send funds from smart contract? also I  
           FuturesContract.send(collateralOfOwner); // ! need to specify send to owner |
           FuturesContract.send(rest); // ! need to specify send  the rest of funds to taker |
       else if (profit < 0) {
           absProfit = (-1 * profit);
           FuturesContract.send(absProfit); // ! need to specify send to owner | this is probably wrong - how to best send funds from smart contract? also I  
           FuturesContract.send(collateralOfTaker); // ! need to specify send to taker |
           FuturesContract.send(rest); // ! need to specify send  the rest of funds to taker |
       }
    }
    //
}
