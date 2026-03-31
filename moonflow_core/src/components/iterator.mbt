package moonflow_core::components

pub struct IteratorComponent

pub enum IteratorType {
  | Forward
  | Backward
  | Random
  | Skip
}

pub fn create_iterator_component() -> IteratorComponent {
  IteratorComponent
}