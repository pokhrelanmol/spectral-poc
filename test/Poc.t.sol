// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import {Test, console} from "forge-std/Test.sol";
import {AutonomousAgentDeployer} from "../src/AutonomousAgentDeployer.sol";
import {AgentBalances} from "../src/AgentBalances.sol";
import {AgentToken} from "../src/AgentToken.sol";
import {ISynapseERC20} from "../src/interfaces/ISynapseERC20.sol";

import {IUniswapV2Factory} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";

contract POC is Test {
    AutonomousAgentDeployer public autonomousAgentDeployer;

    AgentBalances public agentBalances;
    AgentToken public agentToken;
    address public agentTokenImp;
    ISynapseERC20 public synapseERC20;
    SmartContractWallet public smartContractWallet;
    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("PUT_BASE_RPC_HERE"), 26660216);
        autonomousAgentDeployer = AutonomousAgentDeployer(
            0x977FDaA235D15346bFf4e3b3e457887DFf1bdcf3
        );

        agentBalances = AgentBalances(
            0x82ef4B29a5321520FF5829e11eAf2DDcEfa5714F
        );

        agentTokenImp = 0xad67D012f58e06CFbc0AdCd9187e8bcAbE2bC8Dd;

        //Test1 from autonomousAgentDeployer recent deployement
        agentToken = AgentToken(0x8ad6d8c006C5aF6717c4E905b41cDf967610D559);

        synapseERC20 = ISynapseERC20(
            0x96419929d7949D6A801A6909c145C8EEf6A40431
        );

        smartContractWallet = new SmartContractWallet();
    }
}

contract SmartContractWallet {
    // EXAMPLE OF SMART CONTRACT WALLET
    function execute(bytes calldata data, address target) external {
        (bool success, ) = target.call(data);
        require(success, "Execution failed");
    }
}
