package moonflow_core::components

pub struct DebounceComponent

pub enum DebounceStrategy {
  | Leading
  | Trailing
  | Both
}

pub struct DebounceConfig {
  strategy: DebounceStrategy
  delay_ms: Int
  max_wait_ms: Int
}

pub fn create_debounce_component() -> DebounceComponent {
  DebounceComponent
}

pub fn create_debounce_config(strategy: DebounceStrategy, delay_ms: Int) -> DebounceConfig {
  DebounceConfig::{
    strategy,
    delay_ms,
    max_wait_ms: delay_ms * 10,
  }
}
