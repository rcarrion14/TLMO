// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Context.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";
import "/contracts/TLMO.sol";

contract TIENDAVAULT is Context {
    
    TLMO immutable tlmo;
    ERC20 immutable backingCoin;
    uint256 private rate; // TLMO:BACKINGCOING
    uint256 constant ceros = 10**18;
    
    address immutable private adminWallet;
    
    event backingCreated (uint256 cantidadRespaldo, uint256 cantidadEmitida);
    event backingWithdrawn (uint256 cantidadRetirada, uint256 cantidadQuemada);
    event profitPayed (uint256 cantidadPagada);
    

    constructor (address tlmoAddress, address backingCoinAddress, uint256 setRate, address setAdminWallet) {
        
        
        require(address(0) != tlmoAddress , "TIENDAVAULT: set tlmo to the zero address");
        require(address(0) != backingCoinAddress , "TIENDAVAULT: set backingCoin to the zero address");
        require(setRate > 0, "TIENDAVAULT: set rate to be zero");
        require(address(0) != setAdminWallet , "TIENDAVAULT: set adminWallet to the zero address");
        
        tlmo = TLMO(tlmoAddress);
        backingCoin = ERC20(backingCoinAddress);
        rate = setRate * ceros;
        adminWallet = setAdminWallet;
    }    
    
    //VAULT

    function profitPayment(uint256 amount) public {
        require( tlmo.totalSupply() > tlmo.balanceOf(address(this)), "No hay TLMO en circulacion");
        backingCoin.transferFrom(msg.sender, address(this), amount);
        
        rate = (tlmo.totalSupply()-tlmo.balanceOf(address(this)))*ceros/backingCoin.balanceOf(address(this));
        emit profitPayed(amount);
    }

    //ADMIN MAKES A PROFIT PAYMENT
    //Deposits bBTC in the Vault. Now there are more bBTC, so the exchange rate lowers. Clients's TLMO are worth more bBTC.


    function backingWithdraw(uint256 amount) public {  // client gives TLMO, gets bBTC
        require(tlmo.balanceOf(msg.sender)>= amount, "Cliente no tiene suficiente TLMO");
	    require(backingCoin.balanceOf(address(this)) >= amount * ceros / rate, "Vault no tiene suficiente bBTC");

        tlmo.transferFrom(msg.sender, address(this), amount);

        backingCoin.transfer(msg.sender, (amount *ceros/ rate)*9950/10000);
        backingCoin.transfer(adminWallet, (amount *ceros/ rate)*50/10000);  //  la diferencia anterior se transifere al admin
                
        emit backingWithdrawn(amount / rate, amount);        
    }

    // TIENDA
        
    function supplyTLMO() public view returns(uint256){   // TLMO available for buying        
        return tlmo.balanceOf(address(this));        
    }
    
    function priceTLMO() public view returns(uint256){   // amount of TLMO for 1 BTC        
        return rate;        
    }

    function buy(uint256 amount) public {
        require((amount * rate *9950/10000)/ceros <= tlmo.balanceOf(address(this)), "TIENDA: no hay tantos TLMO a la venta");        

        backingCoin.transferFrom(msg.sender, address(this), amount*9950/10000);
        backingCoin.transferFrom(msg.sender, adminWallet, amount*50/10000);

        tlmo.transfer(msg.sender, amount * rate /ceros*9950/10000);
    }

     // THE CLIENT PUTS THE AMOUNT OF bBTC IS WILLING TO SPEND.
     //The contracts sends the TLMO and modifies the variables in order to keep the exchange rate unaltered.

}