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

  fn validate(config: Map[String, String]) -> Bool {
    match config["iterator_type"] {
      Some(itype) => is_valid_iterator_type(itype)
      None => false
    }
  }

  fn get_metadata() -> ComponentMetadata {
    ComponentMetadata::{
      name: "iterator",
      version: "1.0.0",
      description: "Data iteration component with forward, backward, random, and skip support",
      category: ComponentCategory::Tool,
      inputs: [
        InputSchema::{ name: "iterator_type", type_: "string", required: true, description: "Iterator type: forward/backward/random/skip" },
        InputSchema::{ name: "data", type_: "string", required: true, description: "Data to iterate" },
      ],
      outputs: [
        OutputSchema::{ name: "iterations", type_: "array", description: "Iteration results" },
        OutputSchema::{ name: "count", type_: "number", description: "Number of iterations" },
      ],
    }
  }
}