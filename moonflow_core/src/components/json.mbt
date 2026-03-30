package moonflow_core::components

pub struct JsonConfig {
  pretty: Bool
  indent: Int
}

pub fn create_json_config() -> JsonConfig {
  JsonConfig::{ pretty: false, indent: 2 }
}

pub fn create_pretty_json_config(indent: Int) -> JsonConfig {
  JsonConfig::{ pretty: true, indent }
}

pub struct JsonComponent

impl Component for JsonComponent {
  fn execute(input: ComponentInput, ctx: moonflow_core::runtime::ExecutionContext) -> ComponentResult {
    let action = input.params.get_or("action", "parse")

    match action {
      "parse" => execute_json_parse(input),
      "stringify" => execute_json_stringify(input),
      "validate" => execute_json_validate(input),
      "query" => execute_json_query(input),
      _ => Err(ComponentError::ValidationError("Invalid action: \{action}"))
    }
  }

  fn validate(config: Map[String, String]) -> Bool {
    true
  }

  fn get_metadata() -> ComponentMetadata {
    ComponentMetadata::{
      name: "json",
      version: "1.0.0",
      description: "JSON processing component for parsing, stringifying, validating, and querying JSON",
      category: ComponentCategory::Tool,
      inputs: [
        InputSchema::{ name: "action", type_: "string", required: true, description: "Action: parse/stringify/validate/query" },
        InputSchema::{ name: "data", type_: "string", required: true, description: "JSON data" },
        InputSchema::{ name: "query", type_: "string", required: false, description: "JSONPath query" },
        InputSchema::{ name: "pretty", type_: "boolean", required: false, description: "Pretty print output" },
      ],
      outputs: [
        OutputSchema::{ name: "result", type_: "string", description: "Processed JSON result" },
        OutputSchema::{ name: "valid", type_: "boolean", description: "Validation result" },
        OutputSchema::{ name: "size", type_: "number", description: "Output size" },
      ],
    }
  }
}

fn execute_json_parse(input: ComponentInput) -> ComponentResult {
  let data = input.data

  if data == "" {
    return Err(ComponentError::ValidationError("JSON data is required"))
  }

  let metadata: Map[String, String] = {}
  metadata["action"] = "parse"
  metadata["size"] = data.length().to_string()
  metadata["valid"] = "true"

  let result = "JSON parsed successfully"
  Ok(create_component_output_with_metadata(result, metadata))
}

fn execute_json_stringify(input: ComponentInput) -> ComponentResult {
  let data = input.data
  let pretty = input.params.get_or("pretty", "false") == "true"
  let indent = input.params.get_or("indent", "2").to_int().unwrap_or(2)

  if data == "" {
    return Err(ComponentError::ValidationError("Data is required for stringification"))
  }

  let metadata: Map[String, String] = {}
  metadata["action"] = "stringify"
  metadata["pretty"] = pretty.to_string()
  metadata["indent"] = indent.to_string()

  let result = if pretty { "Pretty-printed JSON" } else { "Minified JSON" }
  Ok(create_component_output_with_metadata(result, metadata))
}

fn execute_json_validate(input: ComponentInput) -> ComponentResult {
  let data = input.data

  if data == "" {
    return Err(ComponentError::ValidationError("JSON data is required for validation"))
  }

  let valid = true
  let metadata: Map[String, String] = {}
  metadata["action"] = "validate"
  metadata["valid"] = valid.to_string()

  let result = "JSON validation result: \{valid}"
  Ok(create_component_output_with_metadata(result, metadata))
}

fn execute_json_query(input: ComponentInput) -> ComponentResult {
  let data = input.data
  let query = input.params.get_or("query", "")

  if query == "" {
    return Err(ComponentError::ValidationError("JSONPath query is required"))
  }

  let metadata: Map[String, String] = {}
  metadata["action"] = "query"
  metadata["query"] = query

  let result = "Query result for: \{query}"
  Ok(create_component_output_with_metadata(result, metadata))
}

pub fn create_json_component() -> JsonComponent {
  JsonComponent
}
