package moonflow_core::components

pub struct IteratorComponent

pub enum IteratorType {
  | Forward
  | Backward
  | Random
  | Skip
}

pub struct IteratorConfig {
  iterator_type: IteratorType
  start_index: Int
  end_index: Int?
  step: Int
}

pub fn create_iterator_component() -> IteratorComponent {
  IteratorComponent
}

pub fn create_iterator_config(iterator_type: IteratorType) -> IteratorConfig {
  IteratorConfig::{
    iterator_type,
    start_index: 0,
    end_index: None,
    step: 1,
  }
}