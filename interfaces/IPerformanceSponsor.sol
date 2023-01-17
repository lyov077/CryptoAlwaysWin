// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface IPerformanceSponsor {
   
    struct Sponsor {
        address account;
        uint256 received;
        uint256 balance;
    }

    struct Performance {
        address account;
        uint256 score;
    }

    function calculate(Sponsor[] memory sponsors, uint256 decimal) external view returns(Performance[] memory);
}