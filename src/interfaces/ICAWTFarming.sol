// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface ICAWTFarming {
    enum StakeStatus {
        NOTHING,
        DEPOSITED,
        CLAIMED,
        WITHDRAWN
    }
    struct Stake {
        uint256 amount;
        uint256 checkpoint;
        StakeStatus status;
    }
}