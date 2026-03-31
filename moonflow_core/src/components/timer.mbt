package moonflow_core::components

pub struct TimerComponent

pub enum TimerType {
  | Interval
  | Timeout
  | Delay
}

pub struct TimerConfig {
  timer_type: TimerType
  duration_ms: Int
  repeat: Bool
  max_runs: Int
}

pub fn create_timer_component() -> TimerComponent {
  TimerComponent
}

pub fn create_timer_config(timer_type: TimerType, duration_ms: Int) -> TimerConfig {
  TimerConfig::{
    timer_type,
    duration_ms,
    repeat: false,
    max_runs: 0,
  }
}

pub fn create_repeating_timer_config(timer_type: TimerType, duration_ms: Int, max_runs: Int) -> TimerConfig {
  TimerConfig::{
    timer_type,
    duration_ms,
    repeat: true,
    max_runs,
  }
}