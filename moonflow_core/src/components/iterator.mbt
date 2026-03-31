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

pub fn create_iterator_config_with_range(
  iterator_type: IteratorType,
  start_index: Int,
  end_index: Int,
  step: Int
) -> IteratorConfig {
  IteratorConfig::{
    iterator_type,
    start_index,
    end_index: Some(end_index),
    step,
  }
}

impl Component for IteratorComponent {
  fn execute(input: ComponentInput, ctx: moonflow_core::runtime::ExecutionContext) -> ComponentResult {
    let iterator_type = input.params.get_or("iterator_type", "forward")
    let data = input.data

    if data == "" {
      return Err(ComponentError::ValidationError("Input data is required"))
    }

    execute_iterate_operation(iterator_type, data)
  }