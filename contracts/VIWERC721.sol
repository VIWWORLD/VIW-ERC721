pragma solidity ^0.8.0;
import "./fee/IFeeManager.sol";
import "./access/Ownable.sol";
import "./token/erc721/extensions/ERC721Enumerable.sol";
import "./token/erc20/IERC20.sol";

contract VIWERC721 is ERC721Enumerable, Ownable{
    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    address public feeManager;

    constructor(string memory name, string memory symbol,
        address payable _owner_address, address _feeManager) public ERC721(name, symbol) {
        transferOwnership(_owner_address);
        feeManager = _feeManager;
    }

    function mintInERC20(address _to, uint256 _tokenId, string memory _metadata) external onlyOwner {
        // get fee treasury address
        address feeTreasuryAddress = IFeeManager(feeManager).getFeeTreasuryAddress();
        uint256 feeMintAmount = IFeeManager(feeManager).getFeeERC721Mint();
        address feeContractAddress = IFeeManager(feeManager).getFeeContractAddress();
        // transfer erc20 to treasuryFeeAddress
        IERC20(feeContractAddress).transferFrom(address(msg.sender), feeTreasuryAddress, feeMintAmount);

        super._mint(_to, _tokenId);
        _setTokenURI(_tokenId, _metadata);
    }

    function mintInETH(address _to, uint256 _tokenId, string memory _metadata) external payable onlyOwner {
        // get fee treasury address
        address feeTreasuryAddress = IFeeManager(feeManager).getFeeTreasuryAddress();
        uint256 feeMintEthAmount = IFeeManager(feeManager).getFeeERC721MintInETH();
        // check erc20 fee amount in balance
        require(address(msg.sender).balance >= feeMintEthAmount, "Lack Of ETH Fee Amount");
        // transfer eth to treasuryFeeAddress
        payable(feeTreasuryAddress).transfer(feeMintEthAmount);

        super._mint(_to, _tokenId);
        _setTokenURI(_tokenId, _metadata);
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }


    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        string memory baseURI = _tokenURIs[tokenId];
        return baseURI;
    }

}
