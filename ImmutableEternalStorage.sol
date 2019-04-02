pragma solidity 0.5.3;

import "./ImmutableEternalStorageInterface.sol";

contract ImmutableEternalStorage is ImmutableEternalStorageInterface {
    struct UintEntity {
      uint value;
      bool isEntity;
    }
    struct StringEntity {
      string value;
      bool isEntity;
    }
    struct AddressEntity {
      address value;
      bool isEntity;
    }
    struct BytesEntity {
      bytes value;
      bool isEntity;
    }
    struct Bytes32Entity {
      bytes32 value;
      bool isEntity;
    }
    struct BoolEntity {
      bool value;
      bool isEntity;
    }
    struct IntEntity {
      int value;
      bool isEntity;
    }
    mapping(bytes32 => UintEntity) private uIntStorage;
    mapping(bytes32 => StringEntity) private stringStorage;
    mapping(bytes32 => AddressEntity) private addressStorage;
    mapping(bytes32 => BytesEntity) private bytesStorage;
    mapping(bytes32 => Bytes32Entity) private bytes32Storage;
    mapping(bytes32 => BoolEntity) private boolStorage;
    mapping(bytes32 => IntEntity) private intStorage;

    /********************/
    /** PUBLIC - WRITE **/
    /********************/
    function createUint(bytes32 key, uint value) onlyPrimaryOrOwner external {
        require(!uIntStorage[key].isEntity);

        uIntStorage[key].value = value;
        uIntStorage[key].isEntity = true;
    }

    function createString(bytes32 key, string calldata value) onlyPrimaryOrOwner external {
        require(!stringStorage[key].isEntity);

        stringStorage[key].value = value;
        stringStorage[key].isEntity = true;
    }

    function createAddress(bytes32 key, address value) onlyPrimaryOrOwner external {
        require(!addressStorage[key].isEntity);

        addressStorage[key].value = value;
        addressStorage[key].isEntity = true;
    }

    function createBytes(bytes32 key, bytes calldata value) onlyPrimaryOrOwner external {
        require(!bytesStorage[key].isEntity);

        bytesStorage[key].value = value;
        bytesStorage[key].isEntity = true;
    }

    function createBytes32(bytes32 key, bytes32 value) onlyPrimaryOrOwner external {
        require(!bytes32Storage[key].isEntity);

        bytes32Storage[key].value = value;
        bytes32Storage[key].isEntity = true;
    }

    function createBool(bytes32 key, bool value) onlyPrimaryOrOwner external {
        require(!boolStorage[key].isEntity);

        boolStorage[key].value = value;
        boolStorage[key].isEntity = true;
    }

    function createInt(bytes32 key, int value) onlyPrimaryOrOwner external {
        require(!intStorage[key].isEntity);

        intStorage[key].value = value;
        intStorage[key].isEntity = true;
    }

    /*******************/
    /** PUBLIC - READ **/
    /*******************/
    function getUint(bytes32 key) external view returns(uint) {
        return uIntStorage[key].value;
    }

    function uintExists(bytes32 key) external view returns(bool) {
      return uIntStorage[key].isEntity;
    }

    function getString(bytes32 key) external view returns(string memory) {
        return stringStorage[key].value;
    }

    function stringExists(bytes32 key) external view returns(bool) {
      return stringStorage[key].isEntity;
    }

    function getAddress(bytes32 key) external view returns(address) {
        return addressStorage[key].value;
    }

    function addressExists(bytes32 key) external view returns(bool) {
      return addressStorage[key].isEntity;
    }

    function getBytes(bytes32 key) external view returns(bytes memory) {
        return bytesStorage[key].value;
    }

    function bytesExists(bytes32 key) external view returns(bool) {
      return bytesStorage[key].isEntity;
    }

    function getBytes32(bytes32 key) external view returns(bytes32) {
        return bytes32Storage[key].value;
    }

    function bytes32Exists(bytes32 key) external view returns(bool) {
      return bytes32Storage[key].isEntity;
    }

    function getBool(bytes32 key) external view returns(bool) {
        return boolStorage[key].value;
    }

    function boolExists(bytes32 key) external view returns(bool) {
      return boolStorage[key].isEntity;
    }

    function getInt(bytes32 key) external view returns(int) {
        return intStorage[key].value;
    }

    function intExists(bytes32 key) external view returns(bool) {
      return intStorage[key].isEntity;
    }
}
