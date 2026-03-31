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

pub fn create_multicast_component() -> MulticastComponent {
  MulticastComponent
}

pub fn create_multicast_config(strategy: MulticastStrategy, target_count: Int) -> MulticastConfig {
  MulticastConfig::{
    strategy,
    target_count,
    timeout_ms: 5000,
  }
}

pub fn create_multicast_config_with_timeout(
  strategy: MulticastStrategy,
  target_count: Int,
  timeout_ms: Int
) -> MulticastConfig {
  MulticastConfig::{
    strategy,
    target_count,
    timeout_ms,
  }
}
