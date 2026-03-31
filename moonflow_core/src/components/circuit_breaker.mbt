package moonflow_core::components

pub struct CircuitBreakerComponent

pub enum CircuitState {
  | Closed
  | Open
  | HalfOpen
}

pub struct CircuitBreakerConfig {
  failure_threshold: Int
  success_threshold: Int
  timeout_ms: Int
  half_open_max_calls: Int
}

pub fn create_circuit_breaker_component() -> CircuitBreakerComponent {
  CircuitBreakerComponent
}

pub fn create_circuit_breaker_config(failure_threshold: Int) -> CircuitBreakerConfig {
  CircuitBreakerConfig::{
    failure_threshold,
    success_threshold: 2,
    timeout_ms: 60000,
    half_open_max_calls: 3,
  }
}