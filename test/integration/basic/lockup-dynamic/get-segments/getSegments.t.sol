// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Errors } from "src/libraries/Errors.sol";
import { LockupDynamic } from "src/types/DataTypes.sol";

import { Dynamic_Integration_Basic_Test } from "../Dynamic.t.sol";

contract GetSegments_Dynamic_Integration_Basic_Test is Dynamic_Integration_Basic_Test {
    function test_RevertWhen_Null() external {
        uint256 nullStreamId = 1729;
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2Lockup_Null.selector, nullStreamId));
        dynamic.getSegments(nullStreamId);
    }

    modifier whenNotNull() {
        _;
    }

    function test_GetSegments() external whenNotNull {
        uint256 streamId = createDefaultStream();
        LockupDynamic.Segment[] memory actualSegments = dynamic.getSegments(streamId);
        LockupDynamic.Segment[] memory expectedSegments = defaults.segments();
        assertEq(actualSegments, expectedSegments, "segments");
    }
}