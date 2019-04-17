pragma solidity 0.5.3;

import "./ImmutableEternalStorageInterface.sol";
import "./StatementRegisteryInterface.sol";
import "./plugins/OwnableSecondary.sol";

contract StatementRegistery is StatementRegisteryInterface {
  ImmutableEternalStorageInterface public dataStore;
  string[] public buildingPermitIds;
  mapping(bytes32 => uint) public statementCountByBuildingPermitHash;

  event NewStatementEvent(string indexed buildingPermitId, bytes32 statementId);

  /********************/
  /** PUBLIC - WRITE **/
  /********************/
  constructor(address immutableDataStore) public {
    require(immutableDataStore != address(0), "null data store");
    dataStore = ImmutableEternalStorageInterface(immutableDataStore);
  }

  /* Only to be called by the Controller contract */
  function recordStatement(
    string calldata buildingPermitId,
    uint[] calldata statementDataLayout,
    bytes calldata statementData
  ) external onlyPrimaryOrOwner returns(bytes32) {
    bytes32 statementId = generateNewStatementId(buildingPermitId);

    assert(!statementExists(statementId));

    recordStatementKeyValues(statementId, statementDataLayout, statementData);

    dataStore.createBool(keccak256(abi.encodePacked(statementId)), true);
    updateStatementCountByBuildingPermit(buildingPermitId);

    emit NewStatementEvent(buildingPermitId, statementId);

    return statementId;
  }

  /*******************/
  /** PUBLIC - READ **/
  /*******************/
  function statementIdsByBuildingPermit(string calldata buildingPermitId) external view returns(bytes32[] memory) {
    uint nbStatements = statementCountByBuildingPermit(buildingPermitId);

    bytes32[] memory res = new bytes32[](nbStatements);

    while(nbStatements > 0) {
      nbStatements--;
      res[nbStatements] = computeStatementId(buildingPermitId,nbStatements);
    }

    return res;
  }

  function statementExists(bytes32 statementId) public view returns(bool) {
    return dataStore.boolExists(keccak256(abi.encodePacked(statementId)));
  }

  function getStatementString(bytes32 statementId, string memory key) public view returns(string memory) {
    return dataStore.getString(keccak256(abi.encodePacked(statementId, key)));
  }

  function getStatementPcId(bytes32 statementId) external view returns (string memory) {
    return getStatementString(statementId, "pcId");
  }

  function getStatementAcquisitionDate(bytes32 statementId) external view returns (string memory) {
    return getStatementString(statementId, "acquisitionDate");
  }

  function getStatementRecipient(bytes32 statementId) external view returns (string memory) {
    return getStatementString(statementId, "recipient");
  }

  function getStatementArchitect(bytes32 statementId) external view returns (string memory) {
    return getStatementString(statementId, "architect");
  }

  function getStatementCityHall(bytes32 statementId) external view returns (string memory) {
    return getStatementString(statementId, "cityHall");
  }

  function getStatementMaximumHeight(bytes32 statementId) external view returns (string memory) {
    return getStatementString(statementId, "maximumHeight");
  }

  function getStatementDestination(bytes32 statementId) external view returns (string memory) {
    return getStatementString(statementId, "destination");
  }

  function getStatementSiteArea(bytes32 statementId) external view returns (string memory) {
    return getStatementString(statementId, "siteArea");
  }

  function getStatementBuildingArea(bytes32 statementId) external view returns (string memory) {
    return getStatementString(statementId, "buildingArea");
  }

  function getStatementNearImage(bytes32 statementId) external view returns(string memory) {
    return getStatementString(statementId, "nearImage");
  }

  function getStatementFarImage(bytes32 statementId) external view returns(string memory) {
    return getStatementString(statementId, "farImage");
  }

  function getAllStatements() external view returns(bytes32[] memory) {
    uint nbStatements = 0;
    for(uint idx = 0; idx < buildingPermitIds.length; idx++) {
      nbStatements += statementCountByBuildingPermit(buildingPermitIds[idx]);
    }

    bytes32[] memory res = new bytes32[](nbStatements);

    uint statementIdx = 0;
    for(uint idx = 0; idx < buildingPermitIds.length; idx++) {
      nbStatements = statementCountByBuildingPermit(buildingPermitIds[idx]);
      while(nbStatements > 0){
        nbStatements--;
        res[statementIdx] = computeStatementId(buildingPermitIds[idx],nbStatements);
        statementIdx++;
      }
    }

    return res;
  }

  /**********************/
  /** INTERNAL - WRITE **/
  /**********************/
  function updateStatementCountByBuildingPermit(string memory buildingPermitId) internal {
    uint oldCount = statementCountByBuildingPermitHash[keccak256(abi.encodePacked(buildingPermitId))];

    if(oldCount == 0) { // first record for this building permit id
      buildingPermitIds.push(buildingPermitId);
    }

    uint newCount = oldCount + 1;
    assert(newCount > oldCount);
    statementCountByBuildingPermitHash[keccak256(abi.encodePacked(buildingPermitId))] = newCount;
  }

  function recordStatementKeyValues(
    bytes32 statementId,
    uint[] memory statementDataLayout,
    bytes memory statementData) internal {
    string[] memory infos = parseStatementStrings(statementDataLayout, statementData);

    require(infos.length == 11, "the statement key values array length is incorrect");

    /** enforce the rules given in the legal specifications **/
    // required infos
    require(!isEmpty(infos[0]) && !isEmpty(infos[1]), "acquisitionDate and pcId are required");
    require(!isEmpty(infos[9]) && !isEmpty(infos[10]), "missing image");

    // < 2 missing non required info
    uint nbMissingNRIs = (isEmpty(infos[2]) ? 1 : 0) + (isEmpty(infos[3]) ? 1 : 0) + (isEmpty(infos[4]) ? 1 : 0) + (isEmpty(infos[7]) ? 1 : 0);
    require(nbMissingNRIs <= 2, "> 2 missing non required info");

    // mo missing mandatory info or one missing mandatory info and 0 missing non required info
    uint nbMissingMIs = (isEmpty(infos[5]) ? 1 : 0) + (isEmpty(infos[6]) ? 1 : 0) + (isEmpty(infos[8]) ? 1 : 0);
    require(nbMissingMIs == 0 || (nbMissingMIs == 1 && nbMissingNRIs == 0), "missing mandatory info");

    recordStatementString(statementId, "pcId", infos[0]);
    recordStatementString(statementId, "acquisitionDate", infos[1]);
    if(!isEmpty(infos[2])) recordStatementString(statementId, "recipient", infos[2]);
    if(!isEmpty(infos[3])) recordStatementString(statementId, "architect", infos[3]);
    if(!isEmpty(infos[4])) recordStatementString(statementId, "cityHall", infos[4]);
    if(!isEmpty(infos[5])) recordStatementString(statementId, "maximumHeight", infos[5]);
    if(!isEmpty(infos[6])) recordStatementString(statementId, "destination", infos[6]);
    if(!isEmpty(infos[7])) recordStatementString(statementId, "siteArea", infos[7]);
    if(!isEmpty(infos[8])) recordStatementString(statementId, "buildingArea", infos[8]);
    recordStatementString(statementId, "nearImage", infos[9]);
    recordStatementString(statementId, "farImage", infos[10]);
  }

  function recordStatementString(bytes32 statementId, string memory key, string memory value) internal {
    require(!dataStore.stringExists(keccak256(abi.encodePacked(statementId, key))), "Trying to write an existing key-value string pair");

    dataStore.createString(keccak256(abi.encodePacked(statementId,key)), value);
  }

  /*********************/
  /** INTERNAL - READ **/
  /*********************/
  function generateNewStatementId(string memory buildingPermitId) internal view returns (bytes32) {
    uint nbStatements = statementCountByBuildingPermit(buildingPermitId);
    return computeStatementId(buildingPermitId,nbStatements);
  }

  function statementCountByBuildingPermit(string memory buildingPermitId) internal view returns (uint) {
    return statementCountByBuildingPermitHash[keccak256(abi.encodePacked(buildingPermitId))]; // mapping's default is 0
  }

  function computeStatementId(string memory buildingPermitId, uint statementNb) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(buildingPermitId,statementNb));
  }

  function parseStatementStrings(uint[] memory statementDataLayout, bytes memory statementData) internal pure returns(string[] memory) {
    string[] memory res = new string[](statementDataLayout.length);
    uint bytePos = 0;
    uint resLength = res.length;
    for(uint i = 0; i < resLength; i++) {
      bytes memory strBytes = new bytes(statementDataLayout[i]);
      uint strBytesLength = strBytes.length;
      for(uint j = 0; j < strBytesLength; j++) {
        strBytes[j] = statementData[bytePos];
        bytePos++;
      }
      res[i] = string(strBytes);
    }

    return res;
  }

  function isEmpty(string memory s) internal pure returns(bool) {
    return bytes(s).length == 0;
  }
}
