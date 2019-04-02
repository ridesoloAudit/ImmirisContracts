pragma solidity 0.5.3;

import "./StatementRegisteryInterface.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract Controller is Ownable {
  StatementRegisteryInterface public registery;
  uint public price = 0;
  address payable private _wallet;
  address private _serverSide;

  event LogEvent(string content);
  event NewStatementEvent(string indexed buildingPermitId, bytes32 statementId);

  /********************/
  /** PUBLIC - WRITE **/
  /********************/
  constructor(address registeryAddress, address payable walletAddr, address serverSideAddr) public {
    registery = StatementRegisteryInterface(registeryAddress);
    _wallet = walletAddr;
    _serverSide = serverSideAddr;
  }

  function setPrice(uint priceInWei) external {
    require(msg.sender == owner() || msg.sender == _serverSide);

    price = priceInWei;
  }

  function setWallet(address payable addr) external onlyOwner {
    _wallet = addr;
  }

  function setServerSide(address payable addr) external onlyOwner {
    _serverSide = addr;
  }

  /* record a statement for a given price or for free if the request comes from the server.
  builidngPermitId: the id of the building permit associated with this statement. More than one statement can be recorded for a given permit id
  statementDataLayout: an array containing the length of each string packed in the bytes array, such as [string1Length, string2Length,...]
  statementData: all the strings packed as bytes by the D-App in javascript */
  function recordStatement(string calldata buildingPermitId, uint[] calldata statementDataLayout, bytes calldata statementData) external payable returns(bytes32) {
      if(msg.sender != owner() && msg.sender != _serverSide) {
        require(msg.value >= price, "received insufficient value");

        _wallet.transfer(msg.value); // ETH TRANSFER
      }

      bytes32 statementId = registery.recordStatement(
        buildingPermitId,
        statementDataLayout,
        statementData
      );

      emit NewStatementEvent(buildingPermitId, statementId);

      return statementId;
  }

  /* Transfers the current balance to the owner and terminates the contract.*/
  function destroyAndSend(address payable recipient) external onlyOwner {
    require(registery.primary() != address(this), "trying to destroy the controller while it is still referenced as primary by the registery");
    selfdestruct(recipient);
  }

  /*******************/
  /** PUBLIC - READ **/
  /*******************/
  function wallet() external view returns (address) {
    return _wallet;
  }

  function serverSide() external view returns (address) {
    return _serverSide;
  }

  function statementExists(bytes32 statementId) external view returns (bool) {
    return registery.statementExists(statementId);
  }

  function getStatementIdsByBuildingPermit(string calldata buildingPermitId) external view returns(bytes32[] memory) {
    return registery.statementIdsByBuildingPermit(buildingPermitId);
  }

  function getAllStatements() external view returns(bytes32[] memory) {
    return registery.getAllStatements();
  }

  function getStatementPcId(bytes32 statementId) external view returns (string memory) {
    return registery.getStatementPcId(statementId);
  }

  function getStatementAcquisitionDate(bytes32 statementId) external view returns (string memory) {
    return registery.getStatementAcquisitionDate(statementId);
  }

  function getStatementRecipient(bytes32 statementId) external view returns (string memory) {
    return registery.getStatementRecipient(statementId);
  }

  function getStatementArchitect(bytes32 statementId) external view returns (string memory) {
    return registery.getStatementArchitect(statementId);
  }

  function getStatementCityHall(bytes32 statementId) external view returns (string memory) {
    return registery.getStatementCityHall(statementId);
  }

  function getStatementMaximumHeight(bytes32 statementId) external view returns (string memory) {
    return registery.getStatementMaximumHeight(statementId);
  }

  function getStatementDestination(bytes32 statementId) external view returns (string memory) {
    return registery.getStatementDestination(statementId);
  }

  function getStatementSiteArea(bytes32 statementId) external view returns (string memory) {
    return registery.getStatementSiteArea(statementId);
  }

  function getStatementBuildingArea(bytes32 statementId) external view returns (string memory) {
    return registery.getStatementBuildingArea(statementId);
  }

  function getStatementNearImage(bytes32 statementId) external view returns(string memory) {
    return registery.getStatementNearImage(statementId);
  }

  function getStatementFarImage(bytes32 statementId) external view returns(string memory) {
    return registery.getStatementFarImage(statementId);
  }
}
