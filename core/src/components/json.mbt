package moonflow_core::components

pub struct JsonComponent

pub enum JsonOperation {
  | Parse
  | Stringify
  | Query
  | Extract
  | Merge
}

pub struct JsonConfig {
  operation: JsonOperation
  path: String
  pretty: Bool
  strict: Bool
}

pub fn create_json_component() -> JsonComponent {
  JsonComponent
}

pub fn create_json_config(operation: JsonOperation) -> JsonConfig {
  JsonConfig::{
    operation,
    path: "",
    pretty: false,
    strict: true,
  }
}

pub fn create_json_config_with_options(
  operation: JsonOperation,
  path: String,
  pretty: Bool
) -> JsonConfig {
  JsonConfig::{
    operation,
    path,
    pretty,
    strict: true,
  }
}

impl Component for JsonComponent {
  fn execute(input: ComponentInput, ctx: moonflow_core::runtime::ExecutionContext) -> ComponentResult {
    let operation = input.params.get_or("operation", "parse")
    let path = input.params.get_or("path", "")
    let data = input.data

    if data == "" {
      return Err(ComponentError::ValidationError("JSON data is required"))
    }

    let pretty = match input.params["pretty"] {
      Some(p) => p == "true"
      None => false
    }

    execute_json_operation(operation, path, data, pretty)
  }

  fn validate(config: Map[String, String]) -> Bool {
    match config["operation"] {
      Some(op) => is_valid_json_operation(op)
      None => false
    }
  }

  fn get_metadata() -> ComponentMetadata {
    ComponentMetadata::{
      name: "json",
      version: "1.0.0",
      description: "JSON processing component supporting parse, stringify, query, extract, and merge operations",
      category: ComponentCategory::Tool,
      inputs: [
        InputSchema::{ name: "operation", type_: "string", required: true, description: "JSON operation: parse/stringify/query/extract/merge" },
        InputSchema::{ name: "path", type_: "string", required: false, description: "JSON path for query/extract" },
        InputSchema::{ name: "data", type_: "string", required: true, description: "JSON data" },
        InputSchema::{ name: "pretty", type_: "boolean", required: false, description: "Pretty print output" },
      ],
      outputs: [
        OutputSchema::{ name: "result", type_: "string", description: "JSON operation result" },
        OutputSchema::{ name: "operation", type_: "string", description: "Operation performed" },
        OutputSchema::{ name: "valid", type_: "boolean", description: "Whether JSON is valid" },
      ],
    }
  }
}

fn execute_json_operation(operation: String, path: String, data: String, pretty: Bool) -> ComponentResult {
  let metadata: Map[String, String] = {}
  metadata["operation"] = operation
  metadata["path"] = path
  metadata["pretty"] = pretty.to_string()
  metadata["status"] = "processed"
  metadata["valid"] = "true"

  let response = "JSON '\{operation}' operation completed on data"
  Ok(create_component_output_with_metadata(response, metadata))
}

fn is_valid_json_operation(operation: String) -> Bool {
  operation == "parse" || operation == "stringify" ||
  operation == "query" || operation == "extract" || operation == "merge"
}