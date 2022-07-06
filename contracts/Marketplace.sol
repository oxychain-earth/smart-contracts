// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

import "./OXYToken.sol";

contract Marketplace is Ownable {

    OXYToken public oxyToken;

    mapping(uint256 => uint256) public tokenToPrice;

    event OxygenBought(uint256 _tokenId, address _buyer, uint256 _quantity);

    event OxygenDeposited(uint256 _tokenId, uint256 _quantity, uint256 _price);

    event OxygenWhitdrawn(uint256 _tokenId, uint256 _quantity);

    constructor(address _oxyToken) {
        oxyToken = OXYToken(_oxyToken);
    }

    function buy(uint256 _tokenId, uint256 _quantity, uint256 _price) external payable {
        require(msg.value >= _price * _quantity, "Marketplace::buy(): Matic value sent is insufficient.");
        oxyToken.safeTransferFrom(address(this), msg.sender, _tokenId, _quantity, "");
        emit OxygenBought(_tokenId, msg.sender, _quantity);
    }

    function changePrice(uint256 _tokenId, uint256 _price) external onlyOwner {
        tokenToPrice[_tokenId] = _price;
    }

    function depositOxyTokens(uint256 _tokenId, uint256 _quantity, uint256 _price) external onlyOwner {
        
        oxyToken.safeTransferFrom(msg.sender, address(this), _tokenId, _quantity, "");
        tokenToPrice[_tokenId] = _price;
    
        emit OxygenDeposited(_tokenId, _quantity, _price);
    }

    function withdrawOxyTokens(uint256 _tokenId, uint256 _quantity) external onlyOwner {
        oxyToken.safeTransferFrom(address(this), msg.sender, _tokenId, _quantity, "");
        emit OxygenWhitdrawn(_tokenId, _quantity);
    }

    function withdrawMatic() external onlyOwner {

        uint256 totalBalance = address(this).balance;
        
        (bool withdrawalResult, ) = msg.sender.call{value: totalBalance}("");
        require(withdrawalResult, "Marketplace::withdrawMatic(): Withdrawal failed.");
    }

    function getTokenPrices(uint256[] memory _ids) view external returns (uint256[] memory, uint256[] memory) {
        uint256[] memory tokenPrices = new uint256[](_ids.length);
        for (uint256 i = 0; i < _ids.length; i++) {
            tokenPrices[i] = tokenToPrice[_ids[i]];
        }
        return (_ids, tokenPrices);
    }
}
