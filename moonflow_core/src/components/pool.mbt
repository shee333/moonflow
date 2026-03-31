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
