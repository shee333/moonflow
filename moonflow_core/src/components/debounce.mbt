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
