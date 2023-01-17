// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
interface IAllowList {
    function add(address) external returns(bool);
    function remove(address) external returns(bool);
    function isAllowed(address) external view returns(bool);
}