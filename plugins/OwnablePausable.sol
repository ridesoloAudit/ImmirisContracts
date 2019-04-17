pragma solidity 0.5.3;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract OwnablePausable is Ownable {

  event Paused();
  event Unpaused();
  bool private _paused;

  constructor() internal {
    _paused = false;
    emit Unpaused();
  }

  /**
   * @return true if the contract is paused, false otherwise.
   */
  function paused() public view returns (bool) {
      return _paused;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
      require(!_paused);
      _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
      require(_paused);
      _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() public onlyOwner whenNotPaused {
      _paused = true;
      emit Paused();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyOwner whenPaused {
      _paused = false;
      emit Unpaused();
  }
}
