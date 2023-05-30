// SPDX-License-Identifier: UNLICENSED
// solhint-disable max-line-length,no-console,quotes
pragma solidity >=0.8.19 <0.9.0;

import { console2 } from "forge-std/console2.sol";
import { StdStyle } from "forge-std/StdStyle.sol";
import { Base64 } from "solady/utils/Base64.sol";

import { Linear_Integration_Basic_Test } from "../Linear.t.sol";

/// @dev Requirements for these tests to work:
/// - The stream id must be 1
/// - The stream sender must be `0x6332e7b1deb1f1a0b77b2bb18b144330c7291bca`, i.e. `makeAddr("Sender")`
/// - The stream asset must have the DAI symbol
/// - The contract deployer, i.e. the `sender` config option in `foundry.toml`, must have the default value
/// 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38 so that the deployed contracts have the same addresses as
/// the values hard coded in the tests below
contract TokenURI_Linear_Integration_Basic_Test is Linear_Integration_Basic_Test {
    address internal constant LOCKUP_LINEAR = 0x3381cD18e2Fb4dB236BF0525938AB6E43Db0440f;
    uint256 internal defaultStreamId;

    /// @dev To make these tests noninvasive, they are run only when the contract address matches the hard coded value.
    modifier skipOnMismatch() {
        if (address(linear) == LOCKUP_LINEAR) {
            _;
        } else {
            console2.log(StdStyle.yellow('Warning: "LockupLinear.tokenURI" tests skipped due to address mismatch'));
        }
    }

    function test_RevertWhen_NFTDoesNotExist() external {
        uint256 nullStreamId = 1729;
        vm.expectRevert("ERC721: invalid token ID");
        linear.tokenURI({ tokenId: nullStreamId });
    }

    modifier whenNFTExists() {
        defaultStreamId = createDefaultStream();
        vm.warp({ timestamp: defaults.START_TIME() + defaults.TOTAL_DURATION() / 4 });
        _;
    }

    function test_TokenURI_Decoded() external skipOnMismatch whenNFTExists {
        string memory tokenURI = linear.tokenURI(defaultStreamId);
        string memory actualDecodedTokenURI = string(Base64.decode(tokenURI));
        string memory expectedDecodedTokenURI =
            unicode'data:application/json;base64,{"attributes":[{"trait_type":"Asset","value":"DAI"},{"trait_type":"Sender","value":"0x6332e7b1deb1f1a0b77b2bb18b144330c7291bca"},{"trait_type":"Status","value":"Streaming"}],"description":"This NFT represents a payment stream in a Sablier V2 Lockup Linear contract. The owner of this NFT can withdraw the streamed assets, which are denominated in DAI.\\n\\n- Stream ID: 1\\n- Lockup Linear Address: 0x3381cd18e2fb4db236bf0525938ab6e43db0440f\\n- DAI Address: 0x03a6a84cd762d9707a21605b548aaab891562aab\\n\\n⚠️ WARNING: Transferring the NFT makes the new owner the recipient of the stream. The funds are not automatically withdrawn for the previous recipient.","external_url":"https://sablier.com","name":"Sablier V2 Lockup Linear #1","image":"data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIxMDAwIiBoZWlnaHQ9IjEwMDAiIHZpZXdCb3g9IjAgMCAxMDAwIDEwMDAiPjxyZWN0IHdpZHRoPSIxMDAlIiBoZWlnaHQ9IjEwMCUiIGZpbHRlcj0idXJsKCNOb2lzZSkiLz48cmVjdCB4PSI3MCIgeT0iNzAiIHdpZHRoPSI4NjAiIGhlaWdodD0iODYwIiBmaWxsPSIjZmZmIiBmaWxsLW9wYWNpdHk9Ii4wMyIgcng9IjQ1IiByeT0iNDUiIHN0cm9rZT0iI2ZmZiIgc3Ryb2tlLW9wYWNpdHk9Ii4xIiBzdHJva2Utd2lkdGg9IjQiLz48ZGVmcz48Y2lyY2xlIGlkPSJHbG93IiByPSI1MDAiIGZpbGw9InVybCgjUmFkaWFsR2xvdykiLz48ZmlsdGVyIGlkPSJOb2lzZSI+PGZlRmxvb2QgeD0iMCIgeT0iMCIgd2lkdGg9IjEwMCUiIGhlaWdodD0iMTAwJSIgZmxvb2QtY29sb3I9ImhzbCgyMzAsMjElLDExJSkiIGZsb29kLW9wYWNpdHk9IjEiIHJlc3VsdD0iZmxvb2RGaWxsIi8+PGZlVHVyYnVsZW5jZSBiYXNlRnJlcXVlbmN5PSIuNCIgbnVtT2N0YXZlcz0iMyIgcmVzdWx0PSJOb2lzZSIgdHlwZT0iZnJhY3RhbE5vaXNlIi8+PGZlQmxlbmQgaW49Ik5vaXNlIiBpbjI9ImZsb29kRmlsbCIgbW9kZT0ic29mdC1saWdodCIvPjwvZmlsdGVyPjxwYXRoIGlkPSJMb2dvIiBmaWxsPSIjZmZmIiBmaWxsLW9wYWNpdHk9Ii4xIiBkPSJtMTMzLjU1OSwxMjQuMDM0Yy0uMDEzLDIuNDEyLTEuMDU5LDQuODQ4LTIuOTIzLDYuNDAyLTIuNTU4LDEuODE5LTUuMTY4LDMuNDM5LTcuODg4LDQuOTk2LTE0LjQ0LDguMjYyLTMxLjA0NywxMi41NjUtNDcuNjc0LDEyLjU2OS04Ljg1OC4wMzYtMTcuODM4LTEuMjcyLTI2LjMyOC0zLjY2My05LjgwNi0yLjc2Ni0xOS4wODctNy4xMTMtMjcuNTYyLTEyLjc3OC0xMy44NDItOC4wMjUsOS40NjgtMjguNjA2LDE2LjE1My0zNS4yNjVoMGMyLjAzNS0xLjgzOCw0LjI1Mi0zLjU0Niw2LjQ2My01LjIyNGgwYzYuNDI5LTUuNjU1LDE2LjIxOC0yLjgzNSwyMC4zNTgsNC4xNyw0LjE0Myw1LjA1Nyw4LjgxNiw5LjY0OSwxMy45MiwxMy43MzRoLjAzN2M1LjczNiw2LjQ2MSwxNS4zNTctMi4yNTMsOS4zOC04LjQ4LDAsMC0zLjUxNS0zLjUxNS0zLjUxNS0zLjUxNS0xMS40OS0xMS40NzgtNTIuNjU2LTUyLjY2NC02NC44MzctNjQuODM3bC4wNDktLjAzN2MtMS43MjUtMS42MDYtMi43MTktMy44NDctMi43NTEtNi4yMDRoMGMtLjA0Ni0yLjM3NSwxLjA2Mi00LjU4MiwyLjcyNi02LjIyOWgwbC4xODUtLjE0OGgwYy4wOTktLjA2MiwuMjIyLS4xNDgsLjM3LS4yNTloMGMyLjA2LTEuMzYyLDMuOTUxLTIuNjIxLDYuMDQ0LTMuODQyQzU3Ljc2My0zLjQ3Myw5Ny43Ni0yLjM0MSwxMjguNjM3LDE4LjMzMmMxNi42NzEsOS45NDYtMjYuMzQ0LDU0LjgxMy0zOC42NTEsNDAuMTk5LTYuMjk5LTYuMDk2LTE4LjA2My0xNy43NDMtMTkuNjY4LTE4LjgxMS02LjAxNi00LjA0Ny0xMy4wNjEsNC43NzYtNy43NTIsOS43NTFsNjguMjU0LDY4LjM3MWMxLjcyNCwxLjYwMSwyLjcxNCwzLjg0LDIuNzM4LDYuMTkyWiIvPjxwYXRoIGlkPSJGbG9hdGluZ1RleHQiIGZpbGw9Im5vbmUiIGQ9Ik0xMjUgNDVoNzUwczgwIDAgODAgODB2NzUwczAgODAgLTgwIDgwaC03NTBzLTgwIDAgLTgwIC04MHYtNzUwczAgLTgwIDgwIC04MCIvPjxyYWRpYWxHcmFkaWVudCBpZD0iUmFkaWFsR2xvdyI+PHN0b3Agb2Zmc2V0PSIwJSIgc3RvcC1jb2xvcj0iaHNsKDE5LDIlLDUzJSkiIHN0b3Atb3BhY2l0eT0iLjYiLz48c3RvcCBvZmZzZXQ9IjEwMCUiIHN0b3AtY29sb3I9ImhzbCgyMzAsMjElLDExJSkiIHN0b3Atb3BhY2l0eT0iMCIvPjwvcmFkaWFsR3JhZGllbnQ+PGxpbmVhckdyYWRpZW50IGlkPSJTYW5kVG9wIiB4MT0iMCUiIHkxPSIwJSI+PHN0b3Agb2Zmc2V0PSIwJSIgc3RvcC1jb2xvcj0iaHNsKDE5LDIlLDUzJSkiLz48c3RvcCBvZmZzZXQ9IjEwMCUiIHN0b3AtY29sb3I9ImhzbCgyMzAsMjElLDExJSkiLz48L2xpbmVhckdyYWRpZW50PjxsaW5lYXJHcmFkaWVudCBpZD0iU2FuZEJvdHRvbSIgeDE9IjEwMCUiIHkxPSIxMDAlIj48c3RvcCBvZmZzZXQ9IjEwJSIgc3RvcC1jb2xvcj0iaHNsKDIzMCwyMSUsMTElKSIvPjxzdG9wIG9mZnNldD0iMTAwJSIgc3RvcC1jb2xvcj0iaHNsKDE5LDIlLDUzJSkiLz48YW5pbWF0ZSBhdHRyaWJ1dGVOYW1lPSJ4MSIgZHVyPSI2cyIgcmVwZWF0Q291bnQ9ImluZGVmaW5pdGUiIHZhbHVlcz0iMzAlOzYwJTsxMjAlOzYwJTszMCU7Ii8+PC9saW5lYXJHcmFkaWVudD48bGluZWFyR3JhZGllbnQgaWQ9IkhvdXJnbGFzc1N0cm9rZSIgZ3JhZGllbnRUcmFuc2Zvcm09InJvdGF0ZSg5MCkiIGdyYWRpZW50VW5pdHM9InVzZXJTcGFjZU9uVXNlIj48c3RvcCBvZmZzZXQ9IjUwJSIgc3RvcC1jb2xvcj0iaHNsKDE5LDIlLDUzJSkiLz48c3RvcCBvZmZzZXQ9IjgwJSIgc3RvcC1jb2xvcj0iaHNsKDIzMCwyMSUsMTElKSIvPjwvbGluZWFyR3JhZGllbnQ+PGcgaWQ9IkhvdXJnbGFzcyI+PHBhdGggZD0iTSA1MCwzNjAgYSAzMDAsMzAwIDAgMSwxIDYwMCwwIGEgMzAwLDMwMCAwIDEsMSAtNjAwLDAiIGZpbGw9IiNmZmYiIGZpbGwtb3BhY2l0eT0iLjAyIiBzdHJva2U9InVybCgjSG91cmdsYXNzU3Ryb2tlKSIgc3Ryb2tlLXdpZHRoPSI0Ii8+PHBhdGggZD0ibTU2NiwxNjEuMjAxdi01My45MjRjMC0xOS4zODItMjIuNTEzLTM3LjU2My02My4zOTgtNTEuMTk4LTQwLjc1Ni0xMy41OTItOTQuOTQ2LTIxLjA3OS0xNTIuNTg3LTIxLjA3OXMtMTExLjgzOCw3LjQ4Ny0xNTIuNjAyLDIxLjA3OWMtNDAuODkzLDEzLjYzNi02My40MTMsMzEuODE2LTYzLjQxMyw1MS4xOTh2NTMuOTI0YzAsMTcuMTgxLDE3LjcwNCwzMy40MjcsNTAuMjIzLDQ2LjM5NHYyODQuODA5Yy0zMi41MTksMTIuOTYtNTAuMjIzLDI5LjIwNi01MC4yMjMsNDYuMzk0djUzLjkyNGMwLDE5LjM4MiwyMi41MiwzNy41NjMsNjMuNDEzLDUxLjE5OCw0MC43NjMsMTMuNTkyLDk0Ljk1NCwyMS4wNzksMTUyLjYwMiwyMS4wNzlzMTExLjgzMS03LjQ4NywxNTIuNTg3LTIxLjA3OWM0MC44ODYtMTMuNjM2LDYzLjM5OC0zMS44MTYsNjMuMzk4LTUxLjE5OHYtNTMuOTI0YzAtMTcuMTk2LTE3LjcwNC0zMy40MzUtNTAuMjIzLTQ2LjQwMVYyMDcuNjAzYzMyLjUxOS0xMi45NjcsNTAuMjIzLTI5LjIwNiw1MC4yMjMtNDYuNDAxWm0tMzQ3LjQ2Miw1Ny43OTNsMTMwLjk1OSwxMzEuMDI3LTEzMC45NTksMTMxLjAxM1YyMTguOTk0Wm0yNjIuOTI0LjAyMnYyNjIuMDE4bC0xMzAuOTM3LTEzMS4wMDYsMTMwLjkzNy0xMzEuMDEzWiIgZmlsbD0iIzE2MTgyMiI+PC9wYXRoPjxwb2x5Z29uIHBvaW50cz0iMzUwIDM1MC4wMjYgNDE1LjAzIDI4NC45NzggMjg1IDI4NC45NzggMzUwIDM1MC4wMjYiIGZpbGw9InVybCgjU2FuZEJvdHRvbSkiLz48cGF0aCBkPSJtNDE2LjM0MSwyODEuOTc1YzAsLjkxNC0uMzU0LDEuODA5LTEuMDM1LDIuNjgtNS41NDIsNy4wNzYtMzIuNjYxLDEyLjQ1LTY1LjI4LDEyLjQ1LTMyLjYyNCwwLTU5LjczOC01LjM3NC02NS4yOC0xMi40NS0uNjgxLS44NzItMS4wMzUtMS43NjctMS4wMzUtMi42OCwwLS45MTQuMzU0LTEuODA4LDEuMDM1LTIuNjc2LDUuNTQyLTcuMDc2LDMyLjY1Ni0xMi40NSw2NS4yOC0xMi40NSwzMi42MTksMCw1OS43MzgsNS4zNzQsNjUuMjgsMTIuNDUuNjgxLjg2NywxLjAzNSwxLjc2MiwxLjAzNSwyLjY3NloiIGZpbGw9InVybCgjU2FuZFRvcCkiLz48cGF0aCBkPSJtNDgxLjQ2LDQ4MS41NHY4MS4wMWMtMi4zNS43Ny00LjgyLDEuNTEtNy4zOSwyLjIzLTMwLjMsOC41NC03NC42NSwxMy45Mi0xMjQuMDYsMTMuOTItNTMuNiwwLTEwMS4yNC02LjMzLTEzMS40Ny0xNi4xNnYtODFsNDYuMy00Ni4zMWgxNzAuMzNsNDYuMjksNDYuMzFaIiBmaWxsPSJ1cmwoI1NhbmRCb3R0b20pIi8+PHBhdGggZD0ibTQzNS4xNyw0MzUuMjNjMCwxLjE3LS40NiwyLjMyLTEuMzMsMy40NC03LjExLDkuMDgtNDEuOTMsMTUuOTgtODMuODEsMTUuOThzLTc2LjctNi45LTgzLjgyLTE1Ljk4Yy0uODctMS4xMi0xLjMzLTIuMjctMS4zMy0zLjQ0di0uMDRsOC4zNC04LjM1LjAxLS4wMWMxMy43Mi02LjUxLDQyLjk1LTExLjAyLDc2LjgtMTEuMDJzNjIuOTcsNC40OSw3Ni43MiwxMWw4LjQyLDguNDJaIiBmaWxsPSJ1cmwoI1NhbmRUb3ApIi8+PGcgZmlsbD0ibm9uZSIgc3Ryb2tlPSJ1cmwoI0hvdXJnbGFzc1N0cm9rZSkiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLW1pdGVybGltaXQ9IjEwIiBzdHJva2Utd2lkdGg9IjQiPjxwYXRoIGQ9Im01NjUuNjQxLDEwNy4yOGMwLDkuNTM3LTUuNTYsMTguNjI5LTE1LjY3NiwyNi45NzNoLS4wMjNjLTkuMjA0LDcuNTk2LTIyLjE5NCwxNC41NjItMzguMTk3LDIwLjU5Mi0zOS41MDQsMTQuOTM2LTk3LjMyNSwyNC4zNTUtMTYxLjczMywyNC4zNTUtOTAuNDgsMC0xNjcuOTQ4LTE4LjU4Mi0xOTkuOTUzLTQ0Ljk0OGgtLjAyM2MtMTAuMTE1LTguMzQ0LTE1LjY3Ni0xNy40MzctMTUuNjc2LTI2Ljk3MywwLTM5LjczNSw5Ni41NTQtNzEuOTIxLDIxNS42NTItNzEuOTIxczIxNS42MjksMzIuMTg1LDIxNS42MjksNzEuOTIxWiIvPjxwYXRoIGQ9Im0xMzQuMzYsMTYxLjIwM2MwLDM5LjczNSw5Ni41NTQsNzEuOTIxLDIxNS42NTIsNzEuOTIxczIxNS42MjktMzIuMTg2LDIxNS42MjktNzEuOTIxIi8+PGxpbmUgeDE9IjEzNC4zNiIgeTE9IjE2MS4yMDMiIHgyPSIxMzQuMzYiIHkyPSIxMDcuMjgiLz48bGluZSB4MT0iNTY1LjY0IiB5MT0iMTYxLjIwMyIgeDI9IjU2NS42NCIgeTI9IjEwNy4yOCIvPjxsaW5lIHgxPSIxODQuNTg0IiB5MT0iMjA2LjgyMyIgeDI9IjE4NC41ODUiIHkyPSI1MzcuNTc5Ii8+PGxpbmUgeDE9IjIxOC4xODEiIHkxPSIyMTguMTE4IiB4Mj0iMjE4LjE4MSIgeTI9IjU2Mi41MzciLz48bGluZSB4MT0iNDgxLjgxOCIgeTE9IjIxOC4xNDIiIHgyPSI0ODEuODE5IiB5Mj0iNTYyLjQyOCIvPjxsaW5lIHgxPSI1MTUuNDE1IiB5MT0iMjA3LjM1MiIgeDI9IjUxNS40MTYiIHkyPSI1MzcuNTc5Ii8+PHBhdGggZD0ibTE4NC41OCw1MzcuNThjMCw1LjQ1LDQuMjcsMTAuNjUsMTIuMDMsMTUuNDJoLjAyYzUuNTEsMy4zOSwxMi43OSw2LjU1LDIxLjU1LDkuNDIsMzAuMjEsOS45LDc4LjAyLDE2LjI4LDEzMS44MywxNi4yOCw0OS40MSwwLDkzLjc2LTUuMzgsMTI0LjA2LTEzLjkyLDIuNy0uNzYsNS4yOS0xLjU0LDcuNzUtMi4zNSw4Ljc3LTIuODcsMTYuMDUtNi4wNCwyMS41Ni05LjQzaDBjNy43Ni00Ljc3LDEyLjA0LTkuOTcsMTIuMDQtMTUuNDIiLz48cGF0aCBkPSJtMTg0LjU4Miw0OTIuNjU2Yy0zMS4zNTQsMTIuNDg1LTUwLjIyMywyOC41OC01MC4yMjMsNDYuMTQyLDAsOS41MzYsNS41NjQsMTguNjI3LDE1LjY3NywyNi45NjloLjAyMmM4LjUwMyw3LjAwNSwyMC4yMTMsMTMuNDYzLDM0LjUyNCwxOS4xNTksOS45OTksMy45OTEsMjEuMjY5LDcuNjA5LDMzLjU5NywxMC43ODgsMzYuNDUsOS40MDcsODIuMTgxLDE1LjAwMiwxMzEuODM1LDE1LjAwMnM5NS4zNjMtNS41OTUsMTMxLjgwNy0xNS4wMDJjMTAuODQ3LTIuNzksMjAuODY3LTUuOTI2LDI5LjkyNC05LjM0OSwxLjI0NC0uNDY3LDIuNDczLS45NDIsMy42NzMtMS40MjQsMTQuMzI2LTUuNjk2LDI2LjAzNS0xMi4xNjEsMzQuNTI0LTE5LjE3M2guMDIyYzEwLjExNC04LjM0MiwxNS42NzctMTcuNDMzLDE1LjY3Ny0yNi45NjksMC0xNy41NjItMTguODY5LTMzLjY2NS01MC4yMjMtNDYuMTUiLz48cGF0aCBkPSJtMTM0LjM2LDU5Mi43MmMwLDM5LjczNSw5Ni41NTQsNzEuOTIxLDIxNS42NTIsNzEuOTIxczIxNS42MjktMzIuMTg2LDIxNS42MjktNzEuOTIxIi8+PGxpbmUgeDE9IjEzNC4zNiIgeTE9IjU5Mi43MiIgeDI9IjEzNC4zNiIgeTI9IjUzOC43OTciLz48bGluZSB4MT0iNTY1LjY0IiB5MT0iNTkyLjcyIiB4Mj0iNTY1LjY0IiB5Mj0iNTM4Ljc5NyIvPjxwb2x5bGluZSBwb2ludHM9IjQ4MS44MjIgNDgxLjkwMSA0ODEuNzk4IDQ4MS44NzcgNDgxLjc3NSA0ODEuODU0IDM1MC4wMTUgMzUwLjAyNiAyMTguMTg1IDIxOC4xMjkiLz48cG9seWxpbmUgcG9pbnRzPSIyMTguMTg1IDQ4MS45MDEgMjE4LjIzMSA0ODEuODU0IDM1MC4wMTUgMzUwLjAyNiA0ODEuODIyIDIxOC4xNTIiLz48L2c+PC9nPjxnIGlkPSJQcm9ncmVzcyIgZmlsbD0iI2ZmZiI+PHJlY3Qgd2lkdGg9IjIwOCIgaGVpZ2h0PSIxMDAiIGZpbGwtb3BhY2l0eT0iLjAzIiByeD0iMTUiIHJ5PSIxNSIgc3Ryb2tlPSIjZmZmIiBzdHJva2Utb3BhY2l0eT0iLjEiIHN0cm9rZS13aWR0aD0iNCIvPjx0ZXh0IHg9IjIwIiB5PSIzNCIgZm9udC1mYW1pbHk9IidDb3VyaWVyIE5ldycsQXJpYWwsbW9ub3NwYWNlIiBmb250LXNpemU9IjIycHgiPlByb2dyZXNzPC90ZXh0Pjx0ZXh0IHg9IjIwIiB5PSI3MiIgZm9udC1mYW1pbHk9IidDb3VyaWVyIE5ldycsQXJpYWwsbW9ub3NwYWNlIiBmb250LXNpemU9IjI2cHgiPjI1JTwvdGV4dD48ZyBmaWxsPSJub25lIj48Y2lyY2xlIGN4PSIxNjYiIGN5PSI1MCIgcj0iMjIiIHN0cm9rZT0iaHNsKDIzMCwyMSUsMTElKSIgc3Ryb2tlLXdpZHRoPSIxMCIvPjxjaXJjbGUgY3g9IjE2NiIgY3k9IjUwIiBwYXRoTGVuZ3RoPSIxMDAwMCIgcj0iMjIiIHN0cm9rZT0iaHNsKDE5LDIlLDUzJSkiIHN0cm9rZS1kYXNoYXJyYXk9IjEwMDAwIiBzdHJva2UtZGFzaG9mZnNldD0iNzUwMCIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2Utd2lkdGg9IjUiIHRyYW5zZm9ybT0icm90YXRlKC05MCkiIHRyYW5zZm9ybS1vcmlnaW49IjE2NiA1MCIvPjwvZz48L2c+PGcgaWQ9IlN0YXR1cyIgZmlsbD0iI2ZmZiI+PHJlY3Qgd2lkdGg9IjE4NCIgaGVpZ2h0PSIxMDAiIGZpbGwtb3BhY2l0eT0iLjAzIiByeD0iMTUiIHJ5PSIxNSIgc3Ryb2tlPSIjZmZmIiBzdHJva2Utb3BhY2l0eT0iLjEiIHN0cm9rZS13aWR0aD0iNCIvPjx0ZXh0IHg9IjIwIiB5PSIzNCIgZm9udC1mYW1pbHk9IidDb3VyaWVyIE5ldycsQXJpYWwsbW9ub3NwYWNlIiBmb250LXNpemU9IjIycHgiPlN0YXR1czwvdGV4dD48dGV4dCB4PSIyMCIgeT0iNzIiIGZvbnQtZmFtaWx5PSInQ291cmllciBOZXcnLEFyaWFsLG1vbm9zcGFjZSIgZm9udC1zaXplPSIyNnB4Ij5TdHJlYW1pbmc8L3RleHQ+PC9nPjxnIGlkPSJTdHJlYW1lZCIgZmlsbD0iI2ZmZiI+PHJlY3Qgd2lkdGg9IjE1MiIgaGVpZ2h0PSIxMDAiIGZpbGwtb3BhY2l0eT0iLjAzIiByeD0iMTUiIHJ5PSIxNSIgc3Ryb2tlPSIjZmZmIiBzdHJva2Utb3BhY2l0eT0iLjEiIHN0cm9rZS13aWR0aD0iNCIvPjx0ZXh0IHg9IjIwIiB5PSIzNCIgZm9udC1mYW1pbHk9IidDb3VyaWVyIE5ldycsQXJpYWwsbW9ub3NwYWNlIiBmb250LXNpemU9IjIycHgiPlN0cmVhbWVkPC90ZXh0Pjx0ZXh0IHg9IjIwIiB5PSI3MiIgZm9udC1mYW1pbHk9IidDb3VyaWVyIE5ldycsQXJpYWwsbW9ub3NwYWNlIiBmb250LXNpemU9IjI2cHgiPiYjODgwNTsgMi41MEs8L3RleHQ+PC9nPjxnIGlkPSJEdXJhdGlvbiIgZmlsbD0iI2ZmZiI+PHJlY3Qgd2lkdGg9IjE1MiIgaGVpZ2h0PSIxMDAiIGZpbGwtb3BhY2l0eT0iLjAzIiByeD0iMTUiIHJ5PSIxNSIgc3Ryb2tlPSIjZmZmIiBzdHJva2Utb3BhY2l0eT0iLjEiIHN0cm9rZS13aWR0aD0iNCIvPjx0ZXh0IHg9IjIwIiB5PSIzNCIgZm9udC1mYW1pbHk9IidDb3VyaWVyIE5ldycsQXJpYWwsbW9ub3NwYWNlIiBmb250LXNpemU9IjIycHgiPkR1cmF0aW9uPC90ZXh0Pjx0ZXh0IHg9IjIwIiB5PSI3MiIgZm9udC1mYW1pbHk9IidDb3VyaWVyIE5ldycsQXJpYWwsbW9ub3NwYWNlIiBmb250LXNpemU9IjI2cHgiPiZsdDsgMSBEYXk8L3RleHQ+PC9nPjwvZGVmcz48dGV4dCB0ZXh0LXJlbmRlcmluZz0ib3B0aW1pemVTcGVlZCI+PHRleHRQYXRoIHN0YXJ0T2Zmc2V0PSItMTAwJSIgaHJlZj0iI0Zsb2F0aW5nVGV4dCIgZmlsbD0iI2ZmZiIgZm9udC1mYW1pbHk9IidDb3VyaWVyIE5ldycsQXJpYWwsbW9ub3NwYWNlIiBmaWxsLW9wYWNpdHk9Ii44IiBmb250LXNpemU9IjI2cHgiID48YW5pbWF0ZSBhZGRpdGl2ZT0ic3VtIiBhdHRyaWJ1dGVOYW1lPSJzdGFydE9mZnNldCIgYmVnaW49IjBzIiBkdXI9IjUwcyIgZnJvbT0iMCUiIHJlcGVhdENvdW50PSJpbmRlZmluaXRlIiB0bz0iMTAwJSIvPjB4MzM4MWNkMThlMmZiNGRiMjM2YmYwNTI1OTM4YWI2ZTQzZGIwNDQwZiDigKIgU2FibGllciBWMiBMb2NrdXAgTGluZWFyPC90ZXh0UGF0aD48dGV4dFBhdGggc3RhcnRPZmZzZXQ9IjAlIiBocmVmPSIjRmxvYXRpbmdUZXh0IiBmaWxsPSIjZmZmIiBmb250LWZhbWlseT0iJ0NvdXJpZXIgTmV3JyxBcmlhbCxtb25vc3BhY2UiIGZpbGwtb3BhY2l0eT0iLjgiIGZvbnQtc2l6ZT0iMjZweCIgPjxhbmltYXRlIGFkZGl0aXZlPSJzdW0iIGF0dHJpYnV0ZU5hbWU9InN0YXJ0T2Zmc2V0IiBiZWdpbj0iMHMiIGR1cj0iNTBzIiBmcm9tPSIwJSIgcmVwZWF0Q291bnQ9ImluZGVmaW5pdGUiIHRvPSIxMDAlIi8+MHgzMzgxY2QxOGUyZmI0ZGIyMzZiZjA1MjU5MzhhYjZlNDNkYjA0NDBmIOKAoiBTYWJsaWVyIFYyIExvY2t1cCBMaW5lYXI8L3RleHRQYXRoPjx0ZXh0UGF0aCBzdGFydE9mZnNldD0iLTUwJSIgaHJlZj0iI0Zsb2F0aW5nVGV4dCIgZmlsbD0iI2ZmZiIgZm9udC1mYW1pbHk9IidDb3VyaWVyIE5ldycsQXJpYWwsbW9ub3NwYWNlIiBmaWxsLW9wYWNpdHk9Ii44IiBmb250LXNpemU9IjI2cHgiID48YW5pbWF0ZSBhZGRpdGl2ZT0ic3VtIiBhdHRyaWJ1dGVOYW1lPSJzdGFydE9mZnNldCIgYmVnaW49IjBzIiBkdXI9IjUwcyIgZnJvbT0iMCUiIHJlcGVhdENvdW50PSJpbmRlZmluaXRlIiB0bz0iMTAwJSIvPjB4MDNhNmE4NGNkNzYyZDk3MDdhMjE2MDViNTQ4YWFhYjg5MTU2MmFhYiDigKIgREFJPC90ZXh0UGF0aD48dGV4dFBhdGggc3RhcnRPZmZzZXQ9IjUwJSIgaHJlZj0iI0Zsb2F0aW5nVGV4dCIgZmlsbD0iI2ZmZiIgZm9udC1mYW1pbHk9IidDb3VyaWVyIE5ldycsQXJpYWwsbW9ub3NwYWNlIiBmaWxsLW9wYWNpdHk9Ii44IiBmb250LXNpemU9IjI2cHgiID48YW5pbWF0ZSBhZGRpdGl2ZT0ic3VtIiBhdHRyaWJ1dGVOYW1lPSJzdGFydE9mZnNldCIgYmVnaW49IjBzIiBkdXI9IjUwcyIgZnJvbT0iMCUiIHJlcGVhdENvdW50PSJpbmRlZmluaXRlIiB0bz0iMTAwJSIvPjB4MDNhNmE4NGNkNzYyZDk3MDdhMjE2MDViNTQ4YWFhYjg5MTU2MmFhYiDigKIgREFJPC90ZXh0UGF0aD48L3RleHQ+PHVzZSBocmVmPSIjR2xvdyIgZmlsbC1vcGFjaXR5PSIuOSIvPjx1c2UgaHJlZj0iI0dsb3ciIHg9IjEwMDAiIHk9IjEwMDAiIGZpbGwtb3BhY2l0eT0iLjkiLz48dXNlIGhyZWY9IiNMb2dvIiB4PSIxNzAiIHk9IjE3MCIgdHJhbnNmb3JtPSJzY2FsZSguNikiIC8+PHVzZSBocmVmPSIjSG91cmdsYXNzIiB4PSIxNTAiIHk9IjkwIiB0cmFuc2Zvcm09InJvdGF0ZSgxMCkiIHRyYW5zZm9ybS1vcmlnaW49IjUwMCA1MDAiLz48dXNlIGhyZWY9IiNQcm9ncmVzcyIgeD0iMTI4IiB5PSI3OTAiLz48dXNlIGhyZWY9IiNTdGF0dXMiIHg9IjM1MiIgeT0iNzkwIi8+PHVzZSBocmVmPSIjU3RyZWFtZWQiIHg9IjU1MiIgeT0iNzkwIi8+PHVzZSBocmVmPSIjRHVyYXRpb24iIHg9IjcyMCIgeT0iNzkwIi8+PC9zdmc+"}';
        assertEq(actualDecodedTokenURI, expectedDecodedTokenURI, "decoded token URI");
    }

    function test_TokenURI_Full() external skipOnMismatch whenNFTExists {
        string memory actualTokenURI = linear.tokenURI(defaultStreamId);
        string memory expectedTokenURI =
            "ZGF0YTphcHBsaWNhdGlvbi9qc29uO2Jhc2U2NCx7ImF0dHJpYnV0ZXMiOlt7InRyYWl0X3R5cGUiOiJBc3NldCIsInZhbHVlIjoiREFJIn0seyJ0cmFpdF90eXBlIjoiU2VuZGVyIiwidmFsdWUiOiIweDYzMzJlN2IxZGViMWYxYTBiNzdiMmJiMThiMTQ0MzMwYzcyOTFiY2EifSx7InRyYWl0X3R5cGUiOiJTdGF0dXMiLCJ2YWx1ZSI6IlN0cmVhbWluZyJ9XSwiZGVzY3JpcHRpb24iOiJUaGlzIE5GVCByZXByZXNlbnRzIGEgcGF5bWVudCBzdHJlYW0gaW4gYSBTYWJsaWVyIFYyIExvY2t1cCBMaW5lYXIgY29udHJhY3QuIFRoZSBvd25lciBvZiB0aGlzIE5GVCBjYW4gd2l0aGRyYXcgdGhlIHN0cmVhbWVkIGFzc2V0cywgd2hpY2ggYXJlIGRlbm9taW5hdGVkIGluIERBSS5cblxuLSBTdHJlYW0gSUQ6IDFcbi0gTG9ja3VwIExpbmVhciBBZGRyZXNzOiAweDMzODFjZDE4ZTJmYjRkYjIzNmJmMDUyNTkzOGFiNmU0M2RiMDQ0MGZcbi0gREFJIEFkZHJlc3M6IDB4MDNhNmE4NGNkNzYyZDk3MDdhMjE2MDViNTQ4YWFhYjg5MTU2MmFhYlxuXG7imqDvuI8gV0FSTklORzogVHJhbnNmZXJyaW5nIHRoZSBORlQgbWFrZXMgdGhlIG5ldyBvd25lciB0aGUgcmVjaXBpZW50IG9mIHRoZSBzdHJlYW0uIFRoZSBmdW5kcyBhcmUgbm90IGF1dG9tYXRpY2FsbHkgd2l0aGRyYXduIGZvciB0aGUgcHJldmlvdXMgcmVjaXBpZW50LiIsImV4dGVybmFsX3VybCI6Imh0dHBzOi8vc2FibGllci5jb20iLCJuYW1lIjoiU2FibGllciBWMiBMb2NrdXAgTGluZWFyICMxIiwiaW1hZ2UiOiJkYXRhOmltYWdlL3N2Zyt4bWw7YmFzZTY0LFBITjJaeUI0Yld4dWN6MGlhSFIwY0RvdkwzZDNkeTUzTXk1dmNtY3ZNakF3TUM5emRtY2lJSGRwWkhSb1BTSXhNREF3SWlCb1pXbG5hSFE5SWpFd01EQWlJSFpwWlhkQ2IzZzlJakFnTUNBeE1EQXdJREV3TURBaVBqeHlaV04wSUhkcFpIUm9QU0l4TURBbElpQm9aV2xuYUhROUlqRXdNQ1VpSUdacGJIUmxjajBpZFhKc0tDTk9iMmx6WlNraUx6NDhjbVZqZENCNFBTSTNNQ0lnZVQwaU56QWlJSGRwWkhSb1BTSTROakFpSUdobGFXZG9kRDBpT0RZd0lpQm1hV3hzUFNJalptWm1JaUJtYVd4c0xXOXdZV05wZEhrOUlpNHdNeUlnY25nOUlqUTFJaUJ5ZVQwaU5EVWlJSE4wY205clpUMGlJMlptWmlJZ2MzUnliMnRsTFc5d1lXTnBkSGs5SWk0eElpQnpkSEp2YTJVdGQybGtkR2c5SWpRaUx6NDhaR1ZtY3o0OFkybHlZMnhsSUdsa1BTSkhiRzkzSWlCeVBTSTFNREFpSUdacGJHdzlJblZ5YkNnalVtRmthV0ZzUjJ4dmR5a2lMejQ4Wm1sc2RHVnlJR2xrUFNKT2IybHpaU0krUEdabFJteHZiMlFnZUQwaU1DSWdlVDBpTUNJZ2QybGtkR2c5SWpFd01DVWlJR2hsYVdkb2REMGlNVEF3SlNJZ1pteHZiMlF0WTI5c2IzSTlJbWh6YkNneU16QXNNakVsTERFeEpTa2lJR1pzYjI5a0xXOXdZV05wZEhrOUlqRWlJSEpsYzNWc2REMGlabXh2YjJSR2FXeHNJaTgrUEdabFZIVnlZblZzWlc1alpTQmlZWE5sUm5KbGNYVmxibU41UFNJdU5DSWdiblZ0VDJOMFlYWmxjejBpTXlJZ2NtVnpkV3gwUFNKT2IybHpaU0lnZEhsd1pUMGlabkpoWTNSaGJFNXZhWE5sSWk4K1BHWmxRbXhsYm1RZ2FXNDlJazV2YVhObElpQnBiakk5SW1ac2IyOWtSbWxzYkNJZ2JXOWtaVDBpYzI5bWRDMXNhV2RvZENJdlBqd3ZabWxzZEdWeVBqeHdZWFJvSUdsa1BTSk1iMmR2SWlCbWFXeHNQU0lqWm1abUlpQm1hV3hzTFc5d1lXTnBkSGs5SWk0eElpQmtQU0p0TVRNekxqVTFPU3d4TWpRdU1ETTBZeTB1TURFekxESXVOREV5TFRFdU1EVTVMRFF1T0RRNExUSXVPVEl6TERZdU5EQXlMVEl1TlRVNExERXVPREU1TFRVdU1UWTRMRE11TkRNNUxUY3VPRGc0TERRdU9UazJMVEUwTGpRMExEZ3VNall5TFRNeExqQTBOeXd4TWk0MU5qVXRORGN1TmpjMExERXlMalUyT1MwNExqZzFPQzR3TXpZdE1UY3VPRE00TFRFdU1qY3lMVEkyTGpNeU9DMHpMalkyTXkwNUxqZ3dOaTB5TGpjMk5pMHhPUzR3T0RjdE55NHhNVE10TWpjdU5UWXlMVEV5TGpjM09DMHhNeTQ0TkRJdE9DNHdNalVzT1M0ME5qZ3RNamd1TmpBMkxERTJMakUxTXkwek5TNHlOalZvTUdNeUxqQXpOUzB4TGpnek9DdzBMakkxTWkwekxqVTBOaXcyTGpRMk15MDFMakl5Tkdnd1l6WXVOREk1TFRVdU5qVTFMREUyTGpJeE9DMHlMamd6TlN3eU1DNHpOVGdzTkM0eE55dzBMakUwTXl3MUxqQTFOeXc0TGpneE5pdzVMalkwT1N3eE15NDVNaXd4TXk0M016Um9MakF6TjJNMUxqY3pOaXcyTGpRMk1Td3hOUzR6TlRjdE1pNHlOVE1zT1M0ek9DMDRMalE0TERBc01DMHpMalV4TlMwekxqVXhOUzB6TGpVeE5TMHpMalV4TlMweE1TNDBPUzB4TVM0ME56Z3ROVEl1TmpVMkxUVXlMalkyTkMwMk5DNDRNemN0TmpRdU9ETTNiQzR3TkRrdExqQXpOMk10TVM0M01qVXRNUzQyTURZdE1pNDNNVGt0TXk0NE5EY3RNaTQzTlRFdE5pNHlNRFJvTUdNdExqQTBOaTB5TGpNM05Td3hMakEyTWkwMExqVTRNaXd5TGpjeU5pMDJMakl5T1dnd2JDNHhPRFV0TGpFME9HZ3dZeTR3T1RrdExqQTJNaXd1TWpJeUxTNHhORGdzTGpNM0xTNHlOVGxvTUdNeUxqQTJMVEV1TXpZeUxETXVPVFV4TFRJdU5qSXhMRFl1TURRMExUTXVPRFF5UXpVM0xqYzJNeTB6TGpRM015dzVOeTQzTmkweUxqTTBNU3d4TWpndU5qTTNMREU0TGpNek1tTXhOaTQyTnpFc09TNDVORFl0TWpZdU16UTBMRFUwTGpneE15MHpPQzQyTlRFc05EQXVNVGs1TFRZdU1qazVMVFl1TURrMkxURTRMakEyTXkweE55NDNORE10TVRrdU5qWTRMVEU0TGpneE1TMDJMakF4TmkwMExqQTBOeTB4TXk0d05qRXNOQzQzTnpZdE55NDNOVElzT1M0M05URnNOamd1TWpVMExEWTRMak0zTVdNeExqY3lOQ3d4TGpZd01Td3lMamN4TkN3ekxqZzBMREl1TnpNNExEWXVNVGt5V2lJdlBqeHdZWFJvSUdsa1BTSkdiRzloZEdsdVoxUmxlSFFpSUdacGJHdzlJbTV2Ym1VaUlHUTlJazB4TWpVZ05EVm9OelV3Y3pnd0lEQWdPREFnT0RCMk56VXdjekFnT0RBZ0xUZ3dJRGd3YUMwM05UQnpMVGd3SURBZ0xUZ3dJQzA0TUhZdE56VXdjekFnTFRnd0lEZ3dJQzA0TUNJdlBqeHlZV1JwWVd4SGNtRmthV1Z1ZENCcFpEMGlVbUZrYVdGc1IyeHZkeUkrUEhOMGIzQWdiMlptYzJWMFBTSXdKU0lnYzNSdmNDMWpiMnh2Y2owaWFITnNLREU1TERJbExEVXpKU2tpSUhOMGIzQXRiM0JoWTJsMGVUMGlMallpTHo0OGMzUnZjQ0J2Wm1aelpYUTlJakV3TUNVaUlITjBiM0F0WTI5c2IzSTlJbWh6YkNneU16QXNNakVsTERFeEpTa2lJSE4wYjNBdGIzQmhZMmwwZVQwaU1DSXZQand2Y21Ga2FXRnNSM0poWkdsbGJuUStQR3hwYm1WaGNrZHlZV1JwWlc1MElHbGtQU0pUWVc1a1ZHOXdJaUI0TVQwaU1DVWlJSGt4UFNJd0pTSStQSE4wYjNBZ2IyWm1jMlYwUFNJd0pTSWdjM1J2Y0MxamIyeHZjajBpYUhOc0tERTVMRElsTERVekpTa2lMejQ4YzNSdmNDQnZabVp6WlhROUlqRXdNQ1VpSUhOMGIzQXRZMjlzYjNJOUltaHpiQ2d5TXpBc01qRWxMREV4SlNraUx6NDhMMnhwYm1WaGNrZHlZV1JwWlc1MFBqeHNhVzVsWVhKSGNtRmthV1Z1ZENCcFpEMGlVMkZ1WkVKdmRIUnZiU0lnZURFOUlqRXdNQ1VpSUhreFBTSXhNREFsSWo0OGMzUnZjQ0J2Wm1aelpYUTlJakV3SlNJZ2MzUnZjQzFqYjJ4dmNqMGlhSE5zS0RJek1Dd3lNU1VzTVRFbEtTSXZQanh6ZEc5d0lHOW1abk5sZEQwaU1UQXdKU0lnYzNSdmNDMWpiMnh2Y2owaWFITnNLREU1TERJbExEVXpKU2tpTHo0OFlXNXBiV0YwWlNCaGRIUnlhV0oxZEdWT1lXMWxQU0o0TVNJZ1pIVnlQU0kyY3lJZ2NtVndaV0YwUTI5MWJuUTlJbWx1WkdWbWFXNXBkR1VpSUhaaGJIVmxjejBpTXpBbE96WXdKVHN4TWpBbE96WXdKVHN6TUNVN0lpOCtQQzlzYVc1bFlYSkhjbUZrYVdWdWRENDhiR2x1WldGeVIzSmhaR2xsYm5RZ2FXUTlJa2h2ZFhKbmJHRnpjMU4wY205clpTSWdaM0poWkdsbGJuUlVjbUZ1YzJadmNtMDlJbkp2ZEdGMFpTZzVNQ2tpSUdkeVlXUnBaVzUwVlc1cGRITTlJblZ6WlhKVGNHRmpaVTl1VlhObElqNDhjM1J2Y0NCdlptWnpaWFE5SWpVd0pTSWdjM1J2Y0MxamIyeHZjajBpYUhOc0tERTVMRElsTERVekpTa2lMejQ4YzNSdmNDQnZabVp6WlhROUlqZ3dKU0lnYzNSdmNDMWpiMnh2Y2owaWFITnNLREl6TUN3eU1TVXNNVEVsS1NJdlBqd3ZiR2x1WldGeVIzSmhaR2xsYm5RK1BHY2dhV1E5SWtodmRYSm5iR0Z6Y3lJK1BIQmhkR2dnWkQwaVRTQTFNQ3d6TmpBZ1lTQXpNREFzTXpBd0lEQWdNU3d4SURZd01Dd3dJR0VnTXpBd0xETXdNQ0F3SURFc01TQXROakF3TERBaUlHWnBiR3c5SWlObVptWWlJR1pwYkd3dGIzQmhZMmwwZVQwaUxqQXlJaUJ6ZEhKdmEyVTlJblZ5YkNnalNHOTFjbWRzWVhOelUzUnliMnRsS1NJZ2MzUnliMnRsTFhkcFpIUm9QU0kwSWk4K1BIQmhkR2dnWkQwaWJUVTJOaXd4TmpFdU1qQXhkaTAxTXk0NU1qUmpNQzB4T1M0ek9ESXRNakl1TlRFekxUTTNMalUyTXkwMk15NHpPVGd0TlRFdU1UazRMVFF3TGpjMU5pMHhNeTQxT1RJdE9UUXVPVFEyTFRJeExqQTNPUzB4TlRJdU5UZzNMVEl4TGpBM09YTXRNVEV4TGpnek9DdzNMalE0TnkweE5USXVOakF5TERJeExqQTNPV010TkRBdU9Ea3pMREV6TGpZek5pMDJNeTQwTVRNc016RXVPREUyTFRZekxqUXhNeXcxTVM0eE9UaDJOVE11T1RJMFl6QXNNVGN1TVRneExERTNMamN3TkN3ek15NDBNamNzTlRBdU1qSXpMRFEyTGpNNU5IWXlPRFF1T0RBNVl5MHpNaTQxTVRrc01USXVPVFl0TlRBdU1qSXpMREk1TGpJd05pMDFNQzR5TWpNc05EWXVNemswZGpVekxqa3lOR013TERFNUxqTTRNaXd5TWk0MU1pd3pOeTQxTmpNc05qTXVOREV6TERVeExqRTVPQ3cwTUM0M05qTXNNVE11TlRreUxEazBMamsxTkN3eU1TNHdOemtzTVRVeUxqWXdNaXd5TVM0d056bHpNVEV4TGpnek1TMDNMalE0Tnl3eE5USXVOVGczTFRJeExqQTNPV00wTUM0NE9EWXRNVE11TmpNMkxEWXpMak01T0Mwek1TNDRNVFlzTmpNdU16azRMVFV4TGpFNU9IWXROVE11T1RJMFl6QXRNVGN1TVRrMkxURTNMamN3TkMwek15NDBNelV0TlRBdU1qSXpMVFEyTGpRd01WWXlNRGN1TmpBell6TXlMalV4T1MweE1pNDVOamNzTlRBdU1qSXpMVEk1TGpJd05pdzFNQzR5TWpNdE5EWXVOREF4V20wdE16UTNMalEyTWl3MU55NDNPVE5zTVRNd0xqazFPU3d4TXpFdU1ESTNMVEV6TUM0NU5Ua3NNVE14TGpBeE0xWXlNVGd1T1RrMFdtMHlOakl1T1RJMExqQXlNbll5TmpJdU1ERTRiQzB4TXpBdU9UTTNMVEV6TVM0d01EWXNNVE13TGprek55MHhNekV1TURFeldpSWdabWxzYkQwaUl6RTJNVGd5TWlJK1BDOXdZWFJvUGp4d2IyeDVaMjl1SUhCdmFXNTBjejBpTXpVd0lETTFNQzR3TWpZZ05ERTFMakF6SURJNE5DNDVOemdnTWpnMUlESTROQzQ1TnpnZ016VXdJRE0xTUM0d01qWWlJR1pwYkd3OUluVnliQ2dqVTJGdVpFSnZkSFJ2YlNraUx6NDhjR0YwYUNCa1BTSnROREUyTGpNME1Td3lPREV1T1RjMVl6QXNMamt4TkMwdU16VTBMREV1T0RBNUxURXVNRE0xTERJdU5qZ3ROUzQxTkRJc055NHdOell0TXpJdU5qWXhMREV5TGpRMUxUWTFMakk0TERFeUxqUTFMVE15TGpZeU5Dd3dMVFU1TGpjek9DMDFMak0zTkMwMk5TNHlPQzB4TWk0ME5TMHVOamd4TFM0NE56SXRNUzR3TXpVdE1TNDNOamN0TVM0d016VXRNaTQyT0N3d0xTNDVNVFF1TXpVMExURXVPREE0TERFdU1ETTFMVEl1TmpjMkxEVXVOVFF5TFRjdU1EYzJMRE15TGpZMU5pMHhNaTQwTlN3Mk5TNHlPQzB4TWk0ME5Td3pNaTQyTVRrc01DdzFPUzQzTXpnc05TNHpOelFzTmpVdU1qZ3NNVEl1TkRVdU5qZ3hMamcyTnl3eExqQXpOU3d4TGpjMk1pd3hMakF6TlN3eUxqWTNObG9pSUdacGJHdzlJblZ5YkNnalUyRnVaRlJ2Y0NraUx6NDhjR0YwYUNCa1BTSnRORGd4TGpRMkxEUTRNUzQxTkhZNE1TNHdNV010TWk0ek5TNDNOeTAwTGpneUxERXVOVEV0Tnk0ek9Td3lMakl6TFRNd0xqTXNPQzQxTkMwM05DNDJOU3d4TXk0NU1pMHhNalF1TURZc01UTXVPVEl0TlRNdU5pd3dMVEV3TVM0eU5DMDJMak16TFRFek1TNDBOeTB4Tmk0eE5uWXRPREZzTkRZdU15MDBOaTR6TVdneE56QXVNek5zTkRZdU1qa3NORFl1TXpGYUlpQm1hV3hzUFNKMWNtd29JMU5oYm1SQ2IzUjBiMjBwSWk4K1BIQmhkR2dnWkQwaWJUUXpOUzR4Tnl3ME16VXVNak5qTUN3eExqRTNMUzQwTml3eUxqTXlMVEV1TXpNc015NDBOQzAzTGpFeExEa3VNRGd0TkRFdU9UTXNNVFV1T1RndE9ETXVPREVzTVRVdU9UaHpMVGMyTGpjdE5pNDVMVGd6TGpneUxURTFMams0WXkwdU9EY3RNUzR4TWkweExqTXpMVEl1TWpjdE1TNHpNeTB6TGpRMGRpMHVNRFJzT0M0ek5DMDRMak0xTGpBeExTNHdNV014TXk0M01pMDJMalV4TERReUxqazFMVEV4TGpBeUxEYzJMamd0TVRFdU1ESnpOakl1T1Rjc05DNDBPU3czTmk0M01pd3hNV3c0TGpReUxEZ3VOREphSWlCbWFXeHNQU0oxY213b0kxTmhibVJVYjNBcElpOCtQR2NnWm1sc2JEMGlibTl1WlNJZ2MzUnliMnRsUFNKMWNtd29JMGh2ZFhKbmJHRnpjMU4wY205clpTa2lJSE4wY205clpTMXNhVzVsWTJGd1BTSnliM1Z1WkNJZ2MzUnliMnRsTFcxcGRHVnliR2x0YVhROUlqRXdJaUJ6ZEhKdmEyVXRkMmxrZEdnOUlqUWlQanh3WVhSb0lHUTlJbTAxTmpVdU5qUXhMREV3Tnk0eU9HTXdMRGt1TlRNM0xUVXVOVFlzTVRndU5qSTVMVEUxTGpZM05pd3lOaTQ1TnpOb0xTNHdNak5qTFRrdU1qQTBMRGN1TlRrMkxUSXlMakU1TkN3eE5DNDFOakl0TXpndU1UazNMREl3TGpVNU1pMHpPUzQxTURRc01UUXVPVE0yTFRrM0xqTXlOU3d5TkM0ek5UVXRNVFl4TGpjek15d3lOQzR6TlRVdE9UQXVORGdzTUMweE5qY3VPVFE0TFRFNExqVTRNaTB4T1RrdU9UVXpMVFEwTGprME9HZ3RMakF5TTJNdE1UQXVNVEUxTFRndU16UTBMVEUxTGpZM05pMHhOeTQwTXpjdE1UVXVOamMyTFRJMkxqazNNeXd3TFRNNUxqY3pOU3c1Tmk0MU5UUXROekV1T1RJeExESXhOUzQyTlRJdE56RXVPVEl4Y3pJeE5TNDJNamtzTXpJdU1UZzFMREl4TlM0Mk1qa3NOekV1T1RJeFdpSXZQanh3WVhSb0lHUTlJbTB4TXpRdU16WXNNVFl4TGpJd00yTXdMRE01TGpjek5TdzVOaTQxTlRRc056RXVPVEl4TERJeE5TNDJOVElzTnpFdU9USXhjekl4TlM0Mk1qa3RNekl1TVRnMkxESXhOUzQyTWprdE56RXVPVEl4SWk4K1BHeHBibVVnZURFOUlqRXpOQzR6TmlJZ2VURTlJakUyTVM0eU1ETWlJSGd5UFNJeE16UXVNellpSUhreVBTSXhNRGN1TWpnaUx6NDhiR2x1WlNCNE1UMGlOVFkxTGpZMElpQjVNVDBpTVRZeExqSXdNeUlnZURJOUlqVTJOUzQyTkNJZ2VUSTlJakV3Tnk0eU9DSXZQanhzYVc1bElIZ3hQU0l4T0RRdU5UZzBJaUI1TVQwaU1qQTJMamd5TXlJZ2VESTlJakU0TkM0MU9EVWlJSGt5UFNJMU16Y3VOVGM1SWk4K1BHeHBibVVnZURFOUlqSXhPQzR4T0RFaUlIa3hQU0l5TVRndU1URTRJaUI0TWowaU1qRTRMakU0TVNJZ2VUSTlJalUyTWk0MU16Y2lMejQ4YkdsdVpTQjRNVDBpTkRneExqZ3hPQ0lnZVRFOUlqSXhPQzR4TkRJaUlIZ3lQU0kwT0RFdU9ERTVJaUI1TWowaU5UWXlMalF5T0NJdlBqeHNhVzVsSUhneFBTSTFNVFV1TkRFMUlpQjVNVDBpTWpBM0xqTTFNaUlnZURJOUlqVXhOUzQwTVRZaUlIa3lQU0kxTXpjdU5UYzVJaTgrUEhCaGRHZ2daRDBpYlRFNE5DNDFPQ3cxTXpjdU5UaGpNQ3cxTGpRMUxEUXVNamNzTVRBdU5qVXNNVEl1TURNc01UVXVOREpvTGpBeVl6VXVOVEVzTXk0ek9Td3hNaTQzT1N3MkxqVTFMREl4TGpVMUxEa3VORElzTXpBdU1qRXNPUzQ1TERjNExqQXlMREUyTGpJNExERXpNUzQ0TXl3eE5pNHlPQ3cwT1M0ME1Td3dMRGt6TGpjMkxUVXVNemdzTVRJMExqQTJMVEV6TGpreUxESXVOeTB1TnpZc05TNHlPUzB4TGpVMExEY3VOelV0TWk0ek5TdzRMamMzTFRJdU9EY3NNVFl1TURVdE5pNHdOQ3d5TVM0MU5pMDVMalF6YURCak55NDNOaTAwTGpjM0xERXlMakEwTFRrdU9UY3NNVEl1TURRdE1UVXVORElpTHo0OGNHRjBhQ0JrUFNKdE1UZzBMalU0TWl3ME9USXVOalUyWXkwek1TNHpOVFFzTVRJdU5EZzFMVFV3TGpJeU15d3lPQzQxT0MwMU1DNHlNak1zTkRZdU1UUXlMREFzT1M0MU16WXNOUzQxTmpRc01UZ3VOakkzTERFMUxqWTNOeXd5Tmk0NU5qbG9MakF5TW1NNExqVXdNeXczTGpBd05Td3lNQzR5TVRNc01UTXVORFl6TERNMExqVXlOQ3d4T1M0eE5Ua3NPUzQ1T1Rrc015NDVPVEVzTWpFdU1qWTVMRGN1TmpBNUxETXpMalU1Tnl3eE1DNDNPRGdzTXpZdU5EVXNPUzQwTURjc09ESXVNVGd4TERFMUxqQXdNaXd4TXpFdU9ETTFMREUxTGpBd01uTTVOUzR6TmpNdE5TNDFPVFVzTVRNeExqZ3dOeTB4TlM0d01ESmpNVEF1T0RRM0xUSXVOemtzTWpBdU9EWTNMVFV1T1RJMkxESTVMamt5TkMwNUxqTTBPU3d4TGpJME5DMHVORFkzTERJdU5EY3pMUzQ1TkRJc015NDJOek10TVM0ME1qUXNNVFF1TXpJMkxUVXVOamsyTERJMkxqQXpOUzB4TWk0eE5qRXNNelF1TlRJMExURTVMakUzTTJndU1ESXlZekV3TGpFeE5DMDRMak0wTWl3eE5TNDJOemN0TVRjdU5ETXpMREUxTGpZM055MHlOaTQ1Tmprc01DMHhOeTQxTmpJdE1UZ3VPRFk1TFRNekxqWTJOUzAxTUM0eU1qTXRORFl1TVRVaUx6NDhjR0YwYUNCa1BTSnRNVE0wTGpNMkxEVTVNaTQzTW1Nd0xETTVMamN6TlN3NU5pNDFOVFFzTnpFdU9USXhMREl4TlM0Mk5USXNOekV1T1RJeGN6SXhOUzQyTWprdE16SXVNVGcyTERJeE5TNDJNamt0TnpFdU9USXhJaTgrUEd4cGJtVWdlREU5SWpFek5DNHpOaUlnZVRFOUlqVTVNaTQzTWlJZ2VESTlJakV6TkM0ek5pSWdlVEk5SWpVek9DNDNPVGNpTHo0OGJHbHVaU0I0TVQwaU5UWTFMalkwSWlCNU1UMGlOVGt5TGpjeUlpQjRNajBpTlRZMUxqWTBJaUI1TWowaU5UTTRMamM1TnlJdlBqeHdiMng1YkdsdVpTQndiMmx1ZEhNOUlqUTRNUzQ0TWpJZ05EZ3hMamt3TVNBME9ERXVOems0SURRNE1TNDROemNnTkRneExqYzNOU0EwT0RFdU9EVTBJRE0xTUM0d01UVWdNelV3TGpBeU5pQXlNVGd1TVRnMUlESXhPQzR4TWpraUx6NDhjRzlzZVd4cGJtVWdjRzlwYm5SelBTSXlNVGd1TVRnMUlEUTRNUzQ1TURFZ01qRTRMakl6TVNBME9ERXVPRFUwSURNMU1DNHdNVFVnTXpVd0xqQXlOaUEwT0RFdU9ESXlJREl4T0M0eE5USWlMejQ4TDJjK1BDOW5QanhuSUdsa1BTSlFjbTluY21WemN5SWdabWxzYkQwaUkyWm1aaUkrUEhKbFkzUWdkMmxrZEdnOUlqSXdPQ0lnYUdWcFoyaDBQU0l4TURBaUlHWnBiR3d0YjNCaFkybDBlVDBpTGpBeklpQnllRDBpTVRVaUlISjVQU0l4TlNJZ2MzUnliMnRsUFNJalptWm1JaUJ6ZEhKdmEyVXRiM0JoWTJsMGVUMGlMakVpSUhOMGNtOXJaUzEzYVdSMGFEMGlOQ0l2UGp4MFpYaDBJSGc5SWpJd0lpQjVQU0l6TkNJZ1ptOXVkQzFtWVcxcGJIazlJaWREYjNWeWFXVnlJRTVsZHljc1FYSnBZV3dzYlc5dWIzTndZV05sSWlCbWIyNTBMWE5wZW1VOUlqSXljSGdpUGxCeWIyZHlaWE56UEM5MFpYaDBQangwWlhoMElIZzlJakl3SWlCNVBTSTNNaUlnWm05dWRDMW1ZVzFwYkhrOUlpZERiM1Z5YVdWeUlFNWxkeWNzUVhKcFlXd3NiVzl1YjNOd1lXTmxJaUJtYjI1MExYTnBlbVU5SWpJMmNIZ2lQakkxSlR3dmRHVjRkRDQ4WnlCbWFXeHNQU0p1YjI1bElqNDhZMmx5WTJ4bElHTjRQU0l4TmpZaUlHTjVQU0kxTUNJZ2NqMGlNaklpSUhOMGNtOXJaVDBpYUhOc0tESXpNQ3d5TVNVc01URWxLU0lnYzNSeWIydGxMWGRwWkhSb1BTSXhNQ0l2UGp4amFYSmpiR1VnWTNnOUlqRTJOaUlnWTNrOUlqVXdJaUJ3WVhSb1RHVnVaM1JvUFNJeE1EQXdNQ0lnY2owaU1qSWlJSE4wY205clpUMGlhSE5zS0RFNUxESWxMRFV6SlNraUlITjBjbTlyWlMxa1lYTm9ZWEp5WVhrOUlqRXdNREF3SWlCemRISnZhMlV0WkdGemFHOW1abk5sZEQwaU56VXdNQ0lnYzNSeWIydGxMV3hwYm1WallYQTlJbkp2ZFc1a0lpQnpkSEp2YTJVdGQybGtkR2c5SWpVaUlIUnlZVzV6Wm05eWJUMGljbTkwWVhSbEtDMDVNQ2tpSUhSeVlXNXpabTl5YlMxdmNtbG5hVzQ5SWpFMk5pQTFNQ0l2UGp3dlp6NDhMMmMrUEdjZ2FXUTlJbE4wWVhSMWN5SWdabWxzYkQwaUkyWm1aaUkrUEhKbFkzUWdkMmxrZEdnOUlqRTROQ0lnYUdWcFoyaDBQU0l4TURBaUlHWnBiR3d0YjNCaFkybDBlVDBpTGpBeklpQnllRDBpTVRVaUlISjVQU0l4TlNJZ2MzUnliMnRsUFNJalptWm1JaUJ6ZEhKdmEyVXRiM0JoWTJsMGVUMGlMakVpSUhOMGNtOXJaUzEzYVdSMGFEMGlOQ0l2UGp4MFpYaDBJSGc5SWpJd0lpQjVQU0l6TkNJZ1ptOXVkQzFtWVcxcGJIazlJaWREYjNWeWFXVnlJRTVsZHljc1FYSnBZV3dzYlc5dWIzTndZV05sSWlCbWIyNTBMWE5wZW1VOUlqSXljSGdpUGxOMFlYUjFjend2ZEdWNGRENDhkR1Y0ZENCNFBTSXlNQ0lnZVQwaU56SWlJR1p2Ym5RdFptRnRhV3g1UFNJblEyOTFjbWxsY2lCT1pYY25MRUZ5YVdGc0xHMXZibTl6Y0dGalpTSWdabTl1ZEMxemFYcGxQU0l5Tm5CNElqNVRkSEpsWVcxcGJtYzhMM1JsZUhRK1BDOW5QanhuSUdsa1BTSlRkSEpsWVcxbFpDSWdabWxzYkQwaUkyWm1aaUkrUEhKbFkzUWdkMmxrZEdnOUlqRTFNaUlnYUdWcFoyaDBQU0l4TURBaUlHWnBiR3d0YjNCaFkybDBlVDBpTGpBeklpQnllRDBpTVRVaUlISjVQU0l4TlNJZ2MzUnliMnRsUFNJalptWm1JaUJ6ZEhKdmEyVXRiM0JoWTJsMGVUMGlMakVpSUhOMGNtOXJaUzEzYVdSMGFEMGlOQ0l2UGp4MFpYaDBJSGc5SWpJd0lpQjVQU0l6TkNJZ1ptOXVkQzFtWVcxcGJIazlJaWREYjNWeWFXVnlJRTVsZHljc1FYSnBZV3dzYlc5dWIzTndZV05sSWlCbWIyNTBMWE5wZW1VOUlqSXljSGdpUGxOMGNtVmhiV1ZrUEM5MFpYaDBQangwWlhoMElIZzlJakl3SWlCNVBTSTNNaUlnWm05dWRDMW1ZVzFwYkhrOUlpZERiM1Z5YVdWeUlFNWxkeWNzUVhKcFlXd3NiVzl1YjNOd1lXTmxJaUJtYjI1MExYTnBlbVU5SWpJMmNIZ2lQaVlqT0Rnd05Uc2dNaTQxTUVzOEwzUmxlSFErUEM5blBqeG5JR2xrUFNKRWRYSmhkR2x2YmlJZ1ptbHNiRDBpSTJabVppSStQSEpsWTNRZ2QybGtkR2c5SWpFMU1pSWdhR1ZwWjJoMFBTSXhNREFpSUdacGJHd3RiM0JoWTJsMGVUMGlMakF6SWlCeWVEMGlNVFVpSUhKNVBTSXhOU0lnYzNSeWIydGxQU0lqWm1abUlpQnpkSEp2YTJVdGIzQmhZMmwwZVQwaUxqRWlJSE4wY205clpTMTNhV1IwYUQwaU5DSXZQangwWlhoMElIZzlJakl3SWlCNVBTSXpOQ0lnWm05dWRDMW1ZVzFwYkhrOUlpZERiM1Z5YVdWeUlFNWxkeWNzUVhKcFlXd3NiVzl1YjNOd1lXTmxJaUJtYjI1MExYTnBlbVU5SWpJeWNIZ2lQa1IxY21GMGFXOXVQQzkwWlhoMFBqeDBaWGgwSUhnOUlqSXdJaUI1UFNJM01pSWdabTl1ZEMxbVlXMXBiSGs5SWlkRGIzVnlhV1Z5SUU1bGR5Y3NRWEpwWVd3c2JXOXViM053WVdObElpQm1iMjUwTFhOcGVtVTlJakkyY0hnaVBpWnNkRHNnTVNCRVlYazhMM1JsZUhRK1BDOW5Qand2WkdWbWN6NDhkR1Y0ZENCMFpYaDBMWEpsYm1SbGNtbHVaejBpYjNCMGFXMXBlbVZUY0dWbFpDSStQSFJsZUhSUVlYUm9JSE4wWVhKMFQyWm1jMlYwUFNJdE1UQXdKU0lnYUhKbFpqMGlJMFpzYjJGMGFXNW5WR1Y0ZENJZ1ptbHNiRDBpSTJabVppSWdabTl1ZEMxbVlXMXBiSGs5SWlkRGIzVnlhV1Z5SUU1bGR5Y3NRWEpwWVd3c2JXOXViM053WVdObElpQm1hV3hzTFc5d1lXTnBkSGs5SWk0NElpQm1iMjUwTFhOcGVtVTlJakkyY0hnaUlENDhZVzVwYldGMFpTQmhaR1JwZEdsMlpUMGljM1Z0SWlCaGRIUnlhV0oxZEdWT1lXMWxQU0p6ZEdGeWRFOW1abk5sZENJZ1ltVm5hVzQ5SWpCeklpQmtkWEk5SWpVd2N5SWdabkp2YlQwaU1DVWlJSEpsY0dWaGRFTnZkVzUwUFNKcGJtUmxabWx1YVhSbElpQjBiejBpTVRBd0pTSXZQakI0TXpNNE1XTmtNVGhsTW1aaU5HUmlNak0yWW1Zd05USTFPVE00WVdJMlpUUXpaR0l3TkRRd1ppRGlnS0lnVTJGaWJHbGxjaUJXTWlCTWIyTnJkWEFnVEdsdVpXRnlQQzkwWlhoMFVHRjBhRDQ4ZEdWNGRGQmhkR2dnYzNSaGNuUlBabVp6WlhROUlqQWxJaUJvY21WbVBTSWpSbXh2WVhScGJtZFVaWGgwSWlCbWFXeHNQU0lqWm1abUlpQm1iMjUwTFdaaGJXbHNlVDBpSjBOdmRYSnBaWElnVG1WM0p5eEJjbWxoYkN4dGIyNXZjM0JoWTJVaUlHWnBiR3d0YjNCaFkybDBlVDBpTGpnaUlHWnZiblF0YzJsNlpUMGlNalp3ZUNJZ1BqeGhibWx0WVhSbElHRmtaR2wwYVhabFBTSnpkVzBpSUdGMGRISnBZblYwWlU1aGJXVTlJbk4wWVhKMFQyWm1jMlYwSWlCaVpXZHBiajBpTUhNaUlHUjFjajBpTlRCeklpQm1jbTl0UFNJd0pTSWdjbVZ3WldGMFEyOTFiblE5SW1sdVpHVm1hVzVwZEdVaUlIUnZQU0l4TURBbElpOCtNSGd6TXpneFkyUXhPR1V5Wm1JMFpHSXlNelppWmpBMU1qVTVNemhoWWpabE5ETmtZakEwTkRCbUlPS0FvaUJUWVdKc2FXVnlJRll5SUV4dlkydDFjQ0JNYVc1bFlYSThMM1JsZUhSUVlYUm9QangwWlhoMFVHRjBhQ0J6ZEdGeWRFOW1abk5sZEQwaUxUVXdKU0lnYUhKbFpqMGlJMFpzYjJGMGFXNW5WR1Y0ZENJZ1ptbHNiRDBpSTJabVppSWdabTl1ZEMxbVlXMXBiSGs5SWlkRGIzVnlhV1Z5SUU1bGR5Y3NRWEpwWVd3c2JXOXViM053WVdObElpQm1hV3hzTFc5d1lXTnBkSGs5SWk0NElpQm1iMjUwTFhOcGVtVTlJakkyY0hnaUlENDhZVzVwYldGMFpTQmhaR1JwZEdsMlpUMGljM1Z0SWlCaGRIUnlhV0oxZEdWT1lXMWxQU0p6ZEdGeWRFOW1abk5sZENJZ1ltVm5hVzQ5SWpCeklpQmtkWEk5SWpVd2N5SWdabkp2YlQwaU1DVWlJSEpsY0dWaGRFTnZkVzUwUFNKcGJtUmxabWx1YVhSbElpQjBiejBpTVRBd0pTSXZQakI0TUROaE5tRTROR05rTnpZeVpEazNNRGRoTWpFMk1EVmlOVFE0WVdGaFlqZzVNVFUyTW1GaFlpRGlnS0lnUkVGSlBDOTBaWGgwVUdGMGFENDhkR1Y0ZEZCaGRHZ2djM1JoY25SUFptWnpaWFE5SWpVd0pTSWdhSEpsWmowaUkwWnNiMkYwYVc1blZHVjRkQ0lnWm1sc2JEMGlJMlptWmlJZ1ptOXVkQzFtWVcxcGJIazlJaWREYjNWeWFXVnlJRTVsZHljc1FYSnBZV3dzYlc5dWIzTndZV05sSWlCbWFXeHNMVzl3WVdOcGRIazlJaTQ0SWlCbWIyNTBMWE5wZW1VOUlqSTJjSGdpSUQ0OFlXNXBiV0YwWlNCaFpHUnBkR2wyWlQwaWMzVnRJaUJoZEhSeWFXSjFkR1ZPWVcxbFBTSnpkR0Z5ZEU5bVpuTmxkQ0lnWW1WbmFXNDlJakJ6SWlCa2RYSTlJalV3Y3lJZ1puSnZiVDBpTUNVaUlISmxjR1ZoZEVOdmRXNTBQU0pwYm1SbFptbHVhWFJsSWlCMGJ6MGlNVEF3SlNJdlBqQjRNRE5oTm1FNE5HTmtOell5WkRrM01EZGhNakUyTURWaU5UUTRZV0ZoWWpnNU1UVTJNbUZoWWlEaWdLSWdSRUZKUEM5MFpYaDBVR0YwYUQ0OEwzUmxlSFErUEhWelpTQm9jbVZtUFNJalIyeHZkeUlnWm1sc2JDMXZjR0ZqYVhSNVBTSXVPU0l2UGp4MWMyVWdhSEpsWmowaUkwZHNiM2NpSUhnOUlqRXdNREFpSUhrOUlqRXdNREFpSUdacGJHd3RiM0JoWTJsMGVUMGlMamtpTHo0OGRYTmxJR2h5WldZOUlpTk1iMmR2SWlCNFBTSXhOekFpSUhrOUlqRTNNQ0lnZEhKaGJuTm1iM0p0UFNKelkyRnNaU2d1TmlraUlDOCtQSFZ6WlNCb2NtVm1QU0lqU0c5MWNtZHNZWE56SWlCNFBTSXhOVEFpSUhrOUlqa3dJaUIwY21GdWMyWnZjbTA5SW5KdmRHRjBaU2d4TUNraUlIUnlZVzV6Wm05eWJTMXZjbWxuYVc0OUlqVXdNQ0ExTURBaUx6NDhkWE5sSUdoeVpXWTlJaU5RY205bmNtVnpjeUlnZUQwaU1USTRJaUI1UFNJM09UQWlMejQ4ZFhObElHaHlaV1k5SWlOVGRHRjBkWE1pSUhnOUlqTTFNaUlnZVQwaU56a3dJaTgrUEhWelpTQm9jbVZtUFNJalUzUnlaV0Z0WldRaUlIZzlJalUxTWlJZ2VUMGlOemt3SWk4K1BIVnpaU0JvY21WbVBTSWpSSFZ5WVhScGIyNGlJSGc5SWpjeU1DSWdlVDBpTnprd0lpOCtQQzl6ZG1jKyJ9";
        assertEq(actualTokenURI, expectedTokenURI, "token URI");
    }
}