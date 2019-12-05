#

- BitCoin and Cryptocurrency Technologies A Comprehensive Introduction
- 以太坊白皮书，黄皮书，源代码 https://github.com/ethereum/go-ethereum
- Solidity 文档

- cryptographic hash function
  - collision resistance, hiding, x->H(x)
- digital commitment, digital equivalent of a sealed envelope
  - H(x||nonce)
- puzzle friendly, 事先不知道结果的样式
  - H(block header) <= target
  - proof of work
  - difficult to solve, but easy to verify
  - bitcoin SHA-256
  - asymmetric encryption algorithm