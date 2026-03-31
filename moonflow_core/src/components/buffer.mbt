package moonflow_core::components

pub struct BufferComponent

pub enum BufferStrategy {
  | FlushOnSize
  | FlushOnTime
  | FlushOnSizeOrTime
  | Manual
}

pub struct BufferConfig {
  strategy: BufferStrategy
  max_size: Int
  flush_interval_ms: Int
}

pub fn create_buffer_component() -> BufferComponent {
  BufferComponent
}

pub fn create_buffer_config(strategy: BufferStrategy, max_size: Int) -> BufferConfig {
  BufferConfig::{
    strategy,
    max_size,
    flush_interval_ms: 1000,
  }
}
