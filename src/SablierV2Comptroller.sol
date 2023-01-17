// SPDX-License-Identifier: LGPL-3.0
pragma solidity >=0.8.13;

import { Adminable } from "@prb/contracts/access/Adminable.sol";
import { IERC20 } from "@prb/contracts/token/erc20/IERC20.sol";
import { UD60x18 } from "@prb/math/UD60x18.sol";

import { ISablierV2Comptroller } from "./interfaces/ISablierV2Comptroller.sol";
import { Events } from "./libraries/Events.sol";

/// @title SablierV2Comptroller
/// @dev This contract implements the ISablierV2Comptroller interface.
contract SablierV2Comptroller is
    ISablierV2Comptroller, // one dependency
    Adminable // one dependency
{
    /*//////////////////////////////////////////////////////////////////////////
                                  INTERNAL STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Global fees mapped by ERC-20 asset addresses.
    mapping(IERC20 => UD60x18) internal _protocolFees;

    /*//////////////////////////////////////////////////////////////////////////
                                     CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @param initialAdmin The address of the initial contract admin.
    constructor(address initialAdmin) {
        admin = initialAdmin;
    }

    /*//////////////////////////////////////////////////////////////////////////
                             PUBLIC CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2Comptroller
    function getProtocolFee(IERC20 asset) external view override returns (UD60x18 protocolFee) {
        protocolFee = _protocolFees[asset];
    }

    /*//////////////////////////////////////////////////////////////////////////
                           PUBLIC NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2Comptroller
    function setProtocolFee(IERC20 asset, UD60x18 newFee) external onlyAdmin {
        // Effects: set the new global fee.
        UD60x18 oldFee = _protocolFees[asset];
        _protocolFees[asset] = newFee;

        // Emit an event.
        emit Events.SetProtocolFee({ admin: msg.sender, asset: asset, oldFee: oldFee, newFee: newFee });
    }
}
