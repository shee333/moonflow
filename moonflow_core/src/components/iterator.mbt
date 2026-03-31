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