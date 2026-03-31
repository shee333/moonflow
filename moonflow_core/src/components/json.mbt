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