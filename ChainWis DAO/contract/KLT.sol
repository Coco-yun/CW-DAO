// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract KLT is ERC20, ERC20Permit {
    // 构造函数
    constructor() ERC20("KLT Token", "KLT") ERC20Permit("KLT Token") {
        // 为合约的创建者铸造 10000 * 10**18 个代币
        _mint(msg.sender, 10000000 * 10 ** 18);
    }
}
// 0x1D54D22fb8D85b13bbEb9E8648A618c4B69B5A6f
