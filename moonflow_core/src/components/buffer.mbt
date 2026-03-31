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
