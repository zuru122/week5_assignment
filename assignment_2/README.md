# Solidity Storage, Memory, and Mappings

## 1. Where are your structs, mappings, and arrays stored?

- **Structs**:
  - Declared as **state variables** stored in **storage** (on-chain, permanent).
  - Declared inside functions with `memory` exist temporarily in **memory** (cleared after execution).

- **Mappings**:
  - Always stored in **storage** when declared as state variables.
  - Cannot exist in memory.

- **Arrays**:
  - State-level arrays (fixed or dynamic) **storage**.
  - Function-level arrays with `memory` **memory**, temporary.

> **Key:** Storage persists on-chain; memory is temporary during function execution.



## 2. How do they behave when executed or called?

- **Structs in storage:**
  - Changes persist after function execution.
  - Direct modifications update the contract state permanently.

- **Structs in memory:**
  - Changes are temporary and lost after function execution.

- **Mappings:**
  - Every key maps to a value. If a key hasn’t been set, it returns the default value (`0` for `uint256`, `false` for `bool`).
  - Always persistent on-chain.

- **Arrays:**
  - Storage arrays persist and can be modified permanently.
  - Memory arrays exist only during function execution.

**Example behavior:**

```solidity
mapping(address => uint256) balances;
balances[msg.sender] = 100; // stored permanently
uint256 x = balances[alice]; // returns 0 if alice never received tokens
```
