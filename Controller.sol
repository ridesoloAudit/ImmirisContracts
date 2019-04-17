pragma solidity 0.5.3;

import "./StatementRegisteryInterface.sol";
import "./plugins/OwnablePausable.sol";

contract Controller is OwnablePausable {
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
    require(registeryAddress != address(0), "null registery address");
    require(walletAddr != address(0), "null wallet address");
    require(serverSideAddr != address(0), "null server side address");

    registery = StatementRegisteryInterface(registeryAddress);
    _wallet = walletAddr;
    _serverSide = serverSideAddr;
  }

  /* The price of the service offered by this smart contract is to be updated freely
  by IMMIRIS. It is also updated on a daily basis by the server to reflect the current
  EUR/ETH exchange rate */
  function setPrice(uint priceInWei) external whenNotPaused {
    require(msg.sender == owner() || msg.sender == _serverSide);

    price = priceInWei;
  }

  function setWallet(address payable addr) external onlyOwner whenNotPaused {
    require(addr != address(0), "null wallet address");

    _wallet = addr;
  }

  function setServerSide(address payable addr) external onlyOwner whenNotPaused {
    require(addr != address(0), "null server side address");

    _serverSide = addr;
  }

  /* record a statement for a given price or for free if the request comes from the server.
  builidngPermitId: the id of the building permit associated with this statement. More than one statement can be recorded for a given permit id
  statementDataLayout: an array containing the length of each string packed in the bytes array, such as [string1Length, string2Length,...]
  statementData: all the strings packed as bytes by the D-App in javascript */
  function recordStatement(string calldata buildingPermitId, uint[] calldata statementDataLayout, bytes calldata statementData) external payable whenNotPaused returns(bytes32) {
      if(msg.sender != owner() && msg.sender != _serverSide) {
        require(msg.value >= price, "received insufficient value");

        uint refund = msg.value - price;

        _wallet.transfer(price); // ETH TRANSFER

        if(refund > 0) {
          msg.sender.transfer(refund); // ETH TRANSFER
        }
      }

      bytes32 statementId = registery.recordStatement(
        buildingPermitId,
        statementDataLayout,
        statementData
      );

      emit NewStatementEvent(buildingPermitId, statementId);

      return statementId;
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
