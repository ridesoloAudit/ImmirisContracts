pragma solidity 0.5.3;

import "./plugins/OwnableSecondary.sol";

contract ImmutableEternalStorageInterface is OwnableSecondary {
  /********************/
  /** PUBLIC - WRITE **/
  /********************/
  function createUint(bytes32 key, uint value) external;

  function createString(bytes32 key, string calldata value) external;

  function createAddress(bytes32 key, address value) external;

  function createBytes(bytes32 key, bytes calldata value) external;

  function createBytes32(bytes32 key, bytes32 value) external;

  function createBool(bytes32 key, bool value) external;

  function createInt(bytes32 key, int value) external;

  /*******************/
  /** PUBLIC - READ **/
  /*******************/
  function getUint(bytes32 key) external view returns(uint);

  function uintExists(bytes32 key) external view returns(bool);

  function getString(bytes32 key) external view returns(string memory);

  function stringExists(bytes32 key) external view returns(bool);

  function getAddress(bytes32 key) external view returns(address);

  function addressExists(bytes32 key) external view returns(bool);

  function getBytes(bytes32 key) external view returns(bytes memory);

  function bytesExists(bytes32 key) external view returns(bool);

  function getBytes32(bytes32 key) external view returns(bytes32);

  function bytes32Exists(bytes32 key) external view returns(bool);

  function getBool(bytes32 key) external view returns(bool);

  function boolExists(bytes32 key) external view returns(bool);

  function getInt(bytes32 key) external view returns(int);

  function intExists(bytes32 key) external view returns(bool);
}
