package moonflow_core::components

pub struct PoolComponent

pub enum PoolStrategy {
  | Lifo
  | Fifo
  | Random
}

pub struct PoolConfig {
  strategy: PoolStrategy
  min_size: Int
  max_size: Int
}

pub fn create_pool_component() -> PoolComponent {
  PoolComponent
}

pub fn create_pool_config(strategy: PoolStrategy, max_size: Int) -> PoolConfig {
  PoolConfig::{
    strategy,
    min_size: max_size / 4,
    max_size,
  }
}

pub fn create_pool_config_with_min_max(
  strategy: PoolStrategy,
  min_size: Int,
  max_size: Int
) -> PoolConfig {
  PoolConfig::{
    strategy,
    min_size,
    max_size,
  }
}
