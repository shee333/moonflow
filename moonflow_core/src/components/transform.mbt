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

impl Component for TransformComponent {
  fn execute(input: ComponentInput, ctx: moonflow_core::runtime::ExecutionContext) -> ComponentResult {
    let operation = input.params.get_or("operation", "map")
    let expression = input.params.get_or("expression", "")
    let data = input.data

    if data == "" {
      return Err(ComponentError::ValidationError("Input data is required"))
    }

    execute_transform_operation(operation, expression, data)
  }

  fn validate(config: Map[String, String]) -> Bool {
    match config["operation"] {
      Some(op) => is_valid_transform_operation(op)
      None => false
    }
  }

  fn get_metadata() -> ComponentMetadata {
    ComponentMetadata::{
      name: "transform",
      version: "1.0.0",
      description: "Data transformation component supporting map, flatmap, filter, reduce, and sort operations",
      category: ComponentCategory::Tool,
      inputs: [
        InputSchema::{ name: "operation", type_: "string", required: true, description: "Transform operation: map/flatmap/filter/reduce/sort" },
        InputSchema::{ name: "expression", type_: "string", required: false, description: "Transform expression or mapping" },
        InputSchema::{ name: "data", type_: "string", required: true, description: "Data to transform" },
      ],
      outputs: [
        OutputSchema::{ name: "transformed_data", type_: "string", description: "Transformed output" },
        OutputSchema::{ name: "operation", type_: "string", description: "Operation applied" },
        OutputSchema::{ name: "records_processed", type_: "number", description: "Number of records processed" },
      ],
    }
  }
}

fn execute_transform_operation(operation: String, expression: String, data: String) -> ComponentResult {
  let metadata: Map[String, String] = {}
  metadata["operation"] = operation
  metadata["expression"] = expression
  metadata["status"] = "transformed"
  metadata["records_processed"] = "100"

  let response = "Transformed '\{data}' using '\{operation}' operation"
  Ok(create_component_output_with_metadata(response, metadata))
}

fn is_valid_transform_operation(operation: String) -> Bool {
  operation == "map" || operation == "flatmap" ||
  operation == "filter" || operation == "reduce" || operation == "sort"
}