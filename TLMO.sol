// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "/contracts/Vaulteable.sol";

contract TLMO is Ownable, Vaulteable, ERC20 {
    
    bool minter = true;
    
    constructor (string memory name_, string memory symbol_ ) ERC20(name_, symbol_) {}
    
    
    function mint(address account, uint256 amount) external onlyOwner {  //solo mintea el dueño una vez cuando se arranca el proceso
        require (minter == true, "TLMO: TLMO already minted" );
        _mint(account, amount);
        minter = false ;
    }
    
    function burn(address account, uint256 amount) external virtual onlyVault{ 
        _burn(account, amount);
    }
}