pragma solidity 0.5.3;

import "./plugins/OwnableSecondary.sol";

contract StatementRegisteryInterface is OwnableSecondary {
  /********************/
  /** PUBLIC - WRITE **/
  /********************/
  function recordStatement(string calldata buildingPermitId, uint[] calldata statementDataLayout, bytes calldata statementData) external returns(bytes32);

  /*******************/
  /** PUBLIC - READ **/
  /*******************/
  function statementIdsByBuildingPermit(string calldata id) external view returns(bytes32[] memory);

  function statementExists(bytes32 statementId) public view returns(bool);

  function getStatementString(bytes32 statementId, string memory key) public view returns(string memory);

  function getStatementPcId(bytes32 statementId) external view returns (string memory);

  function getStatementAcquisitionDate(bytes32 statementId) external view returns (string memory);

  function getStatementRecipient(bytes32 statementId) external view returns (string memory);

  function getStatementArchitect(bytes32 statementId) external view returns (string memory);

  function getStatementCityHall(bytes32 statementId) external view returns (string memory);

  function getStatementMaximumHeight(bytes32 statementId) external view returns (string memory);

  function getStatementDestination(bytes32 statementId) external view returns (string memory);

  function getStatementSiteArea(bytes32 statementId) external view returns (string memory);

  function getStatementBuildingArea(bytes32 statementId) external view returns (string memory);

  function getStatementNearImage(bytes32 statementId) external view returns(string memory);

  function getStatementFarImage(bytes32 statementId) external view returns(string memory);

  function getAllStatements() external view returns(bytes32[] memory);
}
