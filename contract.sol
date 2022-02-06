// SPDX-License-Identifier: MIT
// https://bitsofco.de/solidity-function-visibility-explained/
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract EscrowNFT is ERC721Burnable, ERC721Enumerable, Ownable {
    uint256 public tokenCounter = 0;

    // NFT Data
    mapping(uint256 => uint256) public amount;
    mapping(uint256 => uint256) public matureTime;

    // calls a parent constructor to define name and symbol
    constructor() ERC721("EscrowNFT", "ESCRW") {    
    }

    // _recipient is who we send NFT to
    // _amount is Ether escrowed by NFT
    // _matureTime is the time at which NFts funds will be redeemable
    // returns the id of the minted NFT
    function mint(address _recipient, uint256 _amount, uint256 _matureTime) public onlyOwner returns (uint256) {

        //ERC721's internal mint function
        _mint(_recipient, tokenCounter);

        //set values
        amount[tokenCounter] = _amount;
        matureTime[tokenCounter] = _matureTime;

        // increment tokenCounter
        tokenCounter++;

        return tokenCounter - 1; //return ID
    }

    // shows the amount of ether in the amount mapping when you provide the token id
    function tokenDetails(uint256 _tokenId) public view returns (uint256, uint256) {
        require(_exists(_tokenId), "EscrowNFT: Query for nonexistent token");

        return (amount[_tokenId], matureTime[_tokenId]);
    }

    function contractAddress() public view returns (address) {
        return address(this);
    }

    function _beforeTokenTransfer(address _from, address _to, uint256 _amount) internal override(ERC721, ERC721Enumerable) { 

    }

    function supportsInterface(bytes4 _interfaceId) public view virtual override(ERC721, ERC721Enumerable) returns (bool) {

    }

}

contract Escrow is Ownable {

    // two state variables 
    EscrowNFT public escrowNFT; // instance of EscrowNFT that our Escrow contract will use
    bool public initialized = false;

    // events for dapps
    // 3 state changes: creation, redemption, initialization of contract
    event Escrowed(address _from, address _to, uint256 _amount, uint256 _matureTime);
    event Redeemed(address _recipient, uint256 _amount);
    event Initialized(address _escrowNft);

    // initialization
    modifier isInitialized() {
        require(initialized, "Contract is not yet initialized");
        _;
    }

    // external visibility (only external user can call) and onlyOwner can initialize
    function initialize(address _escrowNftAddress) external onlyOwner {
        require(!initialized, "Contract already initialized.");
        escrowNFT = EscrowNFT(_escrowNftAddress);
        initialized = true;

        emit Initialized(_escrowNftAddress);
    }

    // payable type, which can receive ether
    function escrowEth(address _recipient, uint256 _duration) external payable isInitialized {
        require(_recipient != address(0), "Cannot escrow to a blank zero address.");
        require(msg.value > 0, "Cannot escrow 0 ETH");

        uint256 amount = msg.value;
        uint256 matureTime = block.timestamp + _duration;

        escrowNFT.mint(_recipient, amount, matureTime);

        emit Escrowed(msg.sender,
            _recipient,
            amount,
            matureTime);
    }

    function redeemEthFromEscrow(uint256 _tokenId) external isInitialized {
        require(escrowNFT.ownerOf(_tokenId) == msg.sender, "Must own token to claim underlying Eth");

        (uint256 amount, uint256 matureTime) = escrowNFT.tokenDetails(_tokenId);
        require(matureTime <= block.timestamp, "Escrow period not expired.");

        // burn function from ERC721Burnable (destroys the token)
        escrowNFT.burn(_tokenId);

        (bool success, ) = msg.sender.call{value: amount}(" ");

        require(success, "Transfer failed.");

        emit Redeemed(msg.sender, amount);

    }

    // how about a function tat redeems all tokens that have matured?
    function redeemAllAvailableEth() external isInitialized {
        uint256 nftBalance = escrowNFT.balanceOf(msg.sender);
        require(nftBalance > 0, "No escrow NFTs to redeem.");

        // total amount of Eth held in the NFTs 
        uint256 totalAmount = 0;

        for (uint256 i = 0; i < nftBalance; i++) {
            uint tokenId = escrowNFT.tokenOfOwnerByIndex(msg.sender, i);
            (uint256 amount, uint256 matureTime) = escrowNFT.tokenDetails(tokenId);

            if (matureTime <= block.timestamp) {
                escrowNFT.burn(tokenId);
                totalAmount += amount;
            }
        }

        require(totalAmount > 0, "No Ether to redeem.");

        (bool success, ) = msg.sender.call{value: totalAmount}(" ");

        require(success, "Transfer failed.");

        emit Redeemed(msg.sender, totalAmount);

    }

    function contractAddress() public view returns (address) {
        return address(this);
    }

}

/*
1. Initialize Escrow contract
-in EscrowNFT run the view function "contractAddress", then copy the output. This is the initialized contract address for EscrowNFT
-in Escrow, find "initialize" function. paste contents of clipboard into value for _escrowNftAddress and run. This initializes the Escrow contract.
-now, Escrow contract linked to EscrowNFT contract

2. Transfer ownership (set ownership to Escrow) so we can call mint()
-in Escrow, run the view function contractAddress
-in EscrowNFT, find transferOwnership function. paste the output of contractAddress here for newOwner (which is the Escrow contract)
-run transferOwnership function

3. Escrow Eth
-in Escrow, find escrowEth function
-specify your wallet address, a short duration, and a small amount of Ether
-run escrowEth function and approve the metamask popup

4. redeemAllAvailableEth

*/

