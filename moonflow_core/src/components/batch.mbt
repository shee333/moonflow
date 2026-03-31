package moonflow_core::components

pub struct BatchComponent

pub enum BatchMode {
  | Sequential
  | Parallel
  | Chunked
}

pub struct BatchConfig {
  batch_mode: BatchMode
  batch_size: Int
  max_concurrent: Int
}

pub fn create_batch_component() -> BatchComponent {
  BatchComponent
}

pub fn create_batch_config(batch_mode: BatchMode, batch_size: Int) -> BatchConfig {
  BatchConfig::{
    batch_mode,
    batch_size,
    max_concurrent: 1,
  }
}