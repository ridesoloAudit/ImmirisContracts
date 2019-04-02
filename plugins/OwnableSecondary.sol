pragma solidity 0.5.3;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @title Secondary
 * @dev A Secondary contract can only be used by its primary account (the one that created it)
 */
contract OwnableSecondary is Ownable {
  address private _primary;

  event PrimaryTransferred(
    address recipient
  );

  /**
   * @dev Sets the primary account to the one that is creating the Secondary contract.
   */
  constructor() internal {
    _primary = msg.sender;
    emit PrimaryTransferred(_primary);
  }

  /**
   * @dev Reverts if called from any account other than the primary or the owner.
   */
   modifier onlyPrimaryOrOwner() {
     require(msg.sender == _primary || msg.sender == owner(), "not the primary user nor the owner");
     _;
   }

   /**
    * @dev Reverts if called from any account other than the primary.
    */
  modifier onlyPrimary() {
    require(msg.sender == _primary, "not the primary user");
    _;
  }

  /**
   * @return the address of the primary.
   */
  function primary() public view returns (address) {
    return _primary;
  }

  /**
   * @dev Transfers contract to a new primary.
   * @param recipient The address of new primary.
   */
  function transferPrimary(address recipient) public onlyOwner {
    require(recipient != address(0), "not the primary user nor the owner");
    _primary = recipient;
    emit PrimaryTransferred(_primary);
  }
}
