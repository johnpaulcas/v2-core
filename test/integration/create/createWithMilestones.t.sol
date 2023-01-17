// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.13 <0.9.0;

import { IERC20 } from "@prb/contracts/token/erc20/IERC20.sol";
import { UD60x18, ud } from "@prb/math/UD60x18.sol";
import { Solarray } from "solarray/Solarray.sol";

import { Events } from "src/libraries/Events.sol";
import { Status } from "src/types/Enums.sol";
import { LockupAmounts, Broker, LockupCreateAmounts, LockupProStream, Segment } from "src/types/Structs.sol";

import { IntegrationTest } from "../IntegrationTest.t.sol";

abstract contract CreateWithMilestones_Test is IntegrationTest {
    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    constructor(IERC20 asset_, address holder_) IntegrationTest(asset_, holder_) {}

    /*//////////////////////////////////////////////////////////////////////////
                                   SETUP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        IntegrationTest.setUp();

        // Approve the SablierV2LockupPro contract to transfer the asset holder's assets.
        // We use a low-level call to ignore reverts because the asset can have the missing return value bug.
        (bool success, ) = address(asset).call(abi.encodeCall(IERC20.approve, (address(pro), UINT256_MAX)));
        success;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                   TEST FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    struct Params {
        address sender;
        address recipient;
        uint128 grossDepositAmount;
        bool cancelable;
        uint40 startTime;
        Broker broker;
    }

    struct Vars {
        uint256[] initialBalances;
        uint256 initialProBalance;
        uint256 initialBrokerBalance;
        uint128 brokerFeeAmount;
        uint128 netDepositAmount;
        uint256 streamId;
        uint256 actualNextStreamId;
        uint256 expectedNextStreamId;
        address actualNFTOwner;
        address expectedNFTOwner;
        uint256[] actualBalances;
        uint256 actualProBalance;
        uint256 expectedProBalance;
        uint256 actualHolderBalance;
        uint256 expectedHolderBalance;
        uint256 actualBrokerBalance;
        uint256 expectedBrokerBalance;
    }

    /// @dev it should perform the ERC-20 transfers, emit a CreateLockupProStream event, create the stream, record the
    /// protocol fee, bump the next stream id, and mint the NFT.
    ///
    /// The fuzzing ensures that all of the following scenarios are tested:
    ///
    /// - All possible permutations for the funder, recipient, sender, and broker.
    /// - Multiple values for the gross deposit amount.
    /// - Cancelable and non-cancelable.
    /// - Start time in the past, present and future.
    /// - Start time equal and not equal to the first segment milestone.
    /// - Broker fee zero and non-zero.
    function testForkFuzz_CreateWithMilestones(Params memory params) external {
        vm.assume(params.sender != address(0) && params.recipient != address(0) && params.broker.addr != address(0));
        vm.assume(params.broker.addr != holder && params.broker.addr != address(pro));
        vm.assume(params.grossDepositAmount != 0 && params.grossDepositAmount <= initialHolderBalance);
        params.broker.fee = bound(params.broker.fee, 0, DEFAULT_MAX_FEE);
        params.startTime = boundUint40(params.startTime, 0, DEFAULT_SEGMENTS[0].milestone);

        // Load the initial asset balances.
        Vars memory vars;
        vars.initialBalances = getTokenBalances(Solarray.addresses(address(pro), params.broker.addr));
        vars.initialProBalance = vars.initialBalances[0];
        vars.initialBrokerBalance = vars.initialBalances[1];

        // Calculate the fee amounts and the net deposit amount.
        vars.brokerFeeAmount = uint128(ud(params.grossDepositAmount).mul(params.broker.fee).unwrap());
        vars.netDepositAmount = params.grossDepositAmount - vars.brokerFeeAmount;

        // Adjust the segment amounts based on the fuzzed net deposit amount.
        Segment[] memory segments = DEFAULT_SEGMENTS;
        adjustSegmentAmounts(segments, vars.netDepositAmount);

        // Expect an event to be emitted.
        vars.streamId = pro.nextStreamId();
        vm.expectEmit({ checkTopic1: true, checkTopic2: true, checkTopic3: true, checkData: true });
        emit Events.CreateLockupProStream({
            streamId: vars.streamId,
            funder: holder,
            sender: params.sender,
            recipient: params.recipient,
            amounts: LockupCreateAmounts({
                netDeposit: vars.netDepositAmount,
                protocolFee: 0,
                brokerFee: vars.brokerFeeAmount
            }),
            segments: segments,
            asset: asset,
            cancelable: params.cancelable,
            startTime: params.startTime,
            stopTime: DEFAULT_STOP_TIME,
            broker: params.broker.addr
        });

        // Create the stream.
        pro.createWithMilestones(
            params.sender,
            params.recipient,
            params.grossDepositAmount,
            segments,
            asset,
            params.cancelable,
            params.startTime,
            params.broker
        );

        // Assert that the stream was created.
        LockupProStream memory actualStream = pro.getStream(vars.streamId);
        assertEq(actualStream.amounts, LockupAmounts({ deposit: vars.netDepositAmount, withdrawn: 0 }));
        assertEq(actualStream.isCancelable, defaultStream.cancelable);
        assertEq(actualStream.segments, segments);
        assertEq(actualStream.sender, defaultStream.sender);
        assertEq(actualStream.startTime, defaultStream.startTime);
        assertEq(actualStream.status, defaultStream.status);
        assertEq(actualStream.asset, asset);

        // Assert that the next stream id was bumped.
        vars.actualNextStreamId = pro.nextStreamId();
        vars.expectedNextStreamId = vars.streamId + 1;
        assertEq(vars.actualNextStreamId, vars.expectedNextStreamId, "nextStreamId");

        // Assert that the NFT was minted.
        vars.actualNFTOwner = pro.ownerOf({ tokenId: vars.streamId });
        vars.expectedNFTOwner = params.recipient;
        assertEq(vars.actualNFTOwner, vars.expectedNFTOwner, "NFT owner");

        // Load the actual asset balances.
        vars.actualBalances = getTokenBalances(Solarray.addresses(address(pro), holder, params.broker.addr));
        vars.actualProBalance = vars.actualBalances[0];
        vars.actualHolderBalance = vars.actualBalances[1];
        vars.actualBrokerBalance = vars.actualBalances[2];

        // Assert that the contract's balance was updated.
        vars.expectedProBalance = vars.initialProBalance + vars.netDepositAmount;
        assertEq(vars.actualProBalance, vars.expectedProBalance, "contract balance");

        // Assert that the holder's balance was updated.
        vars.expectedHolderBalance = initialHolderBalance - params.grossDepositAmount;
        assertEq(vars.actualHolderBalance, vars.expectedHolderBalance, "holder balance");

        // Assert that the broker's balance was updated.
        vars.expectedBrokerBalance = vars.initialBrokerBalance + vars.brokerFeeAmount;
        assertEq(vars.actualBrokerBalance, vars.expectedBrokerBalance, "broker balance");
    }
}
