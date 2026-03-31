package moonflow_core::components

pub struct TransformComponent

pub enum TransformOperation {
  | Map
  | FlatMap
  | Filter
  | Reduce
  | Sort
}

pub struct TransformConfig {
  operation: TransformOperation
  field_mapping: Map[String, String]
  expression: String
}

pub fn create_transform_component() -> TransformComponent {
  TransformComponent
}

pub fn create_transform_config(operation: TransformOperation, expression: String) -> TransformConfig {
  TransformConfig::{
    operation,
    field_mapping: {},
    expression,
  }
}

pub fn create_transform_config_with_mapping(
  operation: TransformOperation,
  field_mapping: Map[String, String],
  expression: String
) -> TransformConfig {
  TransformConfig::{
    operation,
    field_mapping,
    expression,
  }
}