package moonflow_core::components

pub struct BatchComponent

pub enum BatchMode {
  | Sequential
  | Parallel
  | Chunked
}

pub fn create_batch_component() -> BatchComponent {
  BatchComponent
}