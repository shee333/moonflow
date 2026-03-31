package moonflow_core::components

pub struct MulticastComponent

pub enum MulticastStrategy {
  | Broadcast
  | RoundRobin
  | Random
}

pub struct MulticastConfig {
  strategy: MulticastStrategy
  target_count: Int
  timeout_ms: Int
}
