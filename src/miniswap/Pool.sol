// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

library Tick {
  struct Info {
    bool initialized;
    uint128 liquidity;
  }
}

library Position {
  struct Info {
    uint128 liquidity;
  }
}

contract Pool {
  using Tick for mapping(int24 => Tick.Info);
  using Position for mapping(bytes32 => Position.Info);
  using Position for Position.Info;

  int24 internal constant MIN_TICK = -887272;
  int24 internal constant MAX_TICK = -MIN_TICK;

  // Pool tokens immutable
  address public immutable token0;
  address public immutable token1;

  struct Slot0 {
    uint160 sqrtPriceX96;
    int24 tick;
  }

  Slot0 public slot0;

  uint128 public liquidity;

  // Ticks info
  mapping(int24 => Tick.Info) public ticks;
  mapping(bytes32 => Position.Info) public positions;
}
