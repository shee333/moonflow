///|
/// Circuit breaker component.

///|
pub(all) enum CircuitState {
  Closed
  Open
  HalfOpen
} derive(Show, Eq)

///|
pub(all) struct CircuitBreakerComponent {
  mut state : CircuitState
  failure_threshold : Int
  mut failure_count : Int
  reset_timeout_ms : Int
}

///|
pub fn CircuitBreakerComponent::new(
  failure_threshold? : Int = 5,
  reset_timeout_ms? : Int = 30000,
) -> CircuitBreakerComponent {
  CircuitBreakerComponent::{
    state: Closed,
    failure_threshold,
    failure_count: 0,
    reset_timeout_ms,
  }
}

///|
pub fn CircuitBreakerComponent::is_allowed(
  self : CircuitBreakerComponent,
) -> Bool {
  match self.state {
    Closed => true
    HalfOpen => true
    Open => false
  }
}

///|
pub fn CircuitBreakerComponent::record_success(
  self : CircuitBreakerComponent,
) -> Unit {
  self.failure_count = 0
  self.state = Closed
}

///|
pub fn CircuitBreakerComponent::record_failure(
  self : CircuitBreakerComponent,
) -> Unit {
  self.failure_count = self.failure_count + 1
  if self.failure_count >= self.failure_threshold {
    self.state = Open
  }
}

///|
pub fn CircuitBreakerComponent::info() -> ComponentInfo {
  ComponentInfo::{
    name: "circuit_breaker",
    version: "1.0.0",
    description: "Circuit breaker pattern component",
    category: CatTool,
  }
}
