// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
//导入 uniswap 的 IUniswapV2Router02 接口
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract LockContract is Ownable, IERC20{

    event ERC20Transfer(
        address indexed from,
        address indexed to,
        uint256 amount
    );

    // Errors
    error NotFound();
    error AlreadyExists();
    error InvalidRecipient();
    error InvalidSender();
    error UnsafeRecipient();

    string public name;

    string public symbol;

    uint8 public immutable decimals;

    uint256 public immutable _totalSupply;

    uint256 public minted;

    mapping(address => uint256) public _balanceOf;

    mapping(address => mapping(address => uint256)) public _allowance;

    mapping(address => bool) public whitelist;

    constructor(string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _totalNativeSupply,
        address _owner) Ownable(_owner) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        whitelist[_owner] = true;
        _totalSupply = _totalNativeSupply * (10 ** uint256(decimals));
        _balanceOf[_owner] = _totalSupply;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balanceOf[account];
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowance[owner][spender];
    }

    function setWhitelist(address target, bool state) external onlyOwner {
        whitelist[target] = state;
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _allowance[msg.sender][spender] = amount;
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external override returns (bool) {
        return _transfer(from, to, amount);
    }

    function transfer(address to, uint256 amount) external override returns (bool) {
        return _transfer(msg.sender, to, amount);
    }

    function _transfer(address from, address to, uint256 amount) internal returns (bool) {
        require(to != address(0), "ERC20: transfer to the zero address");
        require(_balanceOf[from] >= amount, "ERC20: transfer amount exceeds balance");
        _balanceOf[from] -= amount;
        _balanceOf[to] += amount;
        emit ERC20Transfer(from, to, amount);
        return true;
    }

    function mint(address to, uint256 amount) external onlyOwner {
        if(to == address(0)){
            revert InvalidRecipient();
        }
        require(minted + amount <= _totalSupply, "ERC20: mint amount exceeds total supply ");
        _balanceOf[to] += amount;
        minted += amount;
        emit ERC20Transfer(address(0), to, amount);
    }

    function _setNameSymbol(string memory _name, string memory _symbol) internal{
        name = _name;
        symbol = _symbol;
    }
}
