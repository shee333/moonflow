package moonflow_core::components

pub struct CircuitBreakerComponent

pub enum CircuitState {
  | Closed
  | Open
  | HalfOpen
}

pub fn create_circuit_breaker_component() -> CircuitBreakerComponent {
  CircuitBreakerComponent
}