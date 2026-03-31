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

pub fn create_batch_config_with_concurrency(
  batch_mode: BatchMode,
  batch_size: Int,
  max_concurrent: Int
) -> BatchConfig {
  BatchConfig::{
    batch_mode,
    batch_size,
    max_concurrent,
  }
}

impl Component for BatchComponent {
  fn execute(input: ComponentInput, ctx: moonflow_core::runtime::ExecutionContext) -> ComponentResult {
    let batch_mode = input.params.get_or("batch_mode", "sequential")
    let batch_size = input.params.get_or("batch_size", "10").to_int()
    let data = input.data

    if data == "" {
      return Err(ComponentError::ValidationError("Input data is required"))
    }

    execute_batch_operation(batch_mode, batch_size, data)
  }