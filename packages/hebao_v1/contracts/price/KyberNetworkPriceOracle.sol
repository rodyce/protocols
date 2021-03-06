// SPDX-License-Identifier: Apache-2.0
// Copyright 2017 Loopring Technology Limited.
pragma solidity ^0.7.0;

import "../iface/PriceOracle.sol";
import "../lib/ERC20.sol";


abstract contract KyberNetworkProxy {
    function getExpectedRate(
        ERC20 src,
        ERC20 dest,
        uint srcQty
        )
        public
        view
        virtual
        returns (
            uint expectedRate,
            uint slippageRate
        );
}

/// @title KyberNetworkPriceOracle
/// @dev Returns the value in Ether for any given ERC20 token.
contract KyberNetworkPriceOracle is PriceOracle
{
    KyberNetworkProxy public immutable kyber;
    address constant public ethTokenInKyber = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    constructor(KyberNetworkProxy _kyber)
    {
        kyber = _kyber;
    }

    function tokenValue(address token, uint amount)
        public
        view
        override
        returns (uint value)
    {
        if (amount == 0) return 0;
        if (token == address(0) || token == ethTokenInKyber) {
            return amount;
        }
        (value,) = kyber.getExpectedRate(
            ERC20(token),
            ERC20(ethTokenInKyber),
            amount
        );
    }
}