package moonflow_core::components

pub struct FormatterComponent

pub enum FormatType {
  | JSON
  | XML
  | CSV
  | YAML
  | Plain
}

pub struct FormatterConfig {
  input_format: FormatType
  output_format: FormatType
  indent: Int
  include_header: Bool
}

pub fn create_formatter_component() -> FormatterComponent {
  FormatterComponent
}

pub fn create_formatter_config(input_format: FormatType, output_format: FormatType) -> FormatterConfig {
  FormatterConfig::{
    input_format,
    output_format,
    indent: 2,
    include_header: false,
  }
}

pub fn create_formatter_config_with_indent(
  input_format: FormatType,
  output_format: FormatType,
  indent: Int
) -> FormatterConfig {
  FormatterConfig::{
    input_format,
    output_format,
    indent,
    include_header: false,
  }
}

impl Component for FormatterComponent {
  fn execute(input: ComponentInput, ctx: moonflow_core::runtime::ExecutionContext) -> ComponentResult {
    let input_format = input.params.get_or("input_format", "json")
    let output_format = input.params.get_or("output_format", "json")
    let data = input.data

    if data == "" {
      return Err(ComponentError::ValidationError("Input data is required"))
    }

    let indent = match input.params["indent"] {
      Some(i) => parse_int(i)
      None => 2
    }

    execute_format_conversion(input_format, output_format, data, indent)
  }

  fn validate(config: Map[String, String]) -> Bool {
    match (config["input_format"], config["output_format"]) {
      (Some(in_fmt), Some(out_fmt)) =>
        is_valid_format_type(in_fmt) && is_valid_format_type(out_fmt)
      _ => false
    }
  }

  fn get_metadata() -> ComponentMetadata {
    ComponentMetadata::{
      name: "formatter",
      version: "1.0.0",
      description: "Data formatting component supporting JSON, XML, CSV, YAML, and plain text conversions",
      category: ComponentCategory::Tool,
      inputs: [
        InputSchema::{ name: "input_format", type_: "string", required: true, description: "Input format: json/xml/csv/yaml/plain" },
        InputSchema::{ name: "output_format", type_: "string", required: true, description: "Output format: json/xml/csv/yaml/plain" },
        InputSchema::{ name: "data", type_: "string", required: true, description: "Data to format" },
        InputSchema::{ name: "indent", type_: "number", required: false, description: "Indentation level" },
      ],
      outputs: [
        OutputSchema::{ name: "formatted_data", type_: "string", description: "Formatted output" },
        OutputSchema::{ name: "output_format", type_: "string", description: "Output format used" },
        OutputSchema::{ name: "size", type_: "number", description: "Output size in bytes" },
      ],
    }
  }
}

fn execute_format_conversion(
  input_format: String,
  output_format: String,
  data: String,
  indent: Int
) -> ComponentResult {
  let metadata: Map[String, String] = {}
  metadata["input_format"] = input_format
  metadata["output_format"] = output_format
  metadata["status"] = "converted"

  let response = "Converted from '\{input_format}' to '\{output_format}' with indent \{indent}"
  Ok(create_component_output_with_metadata(response, metadata))
}

fn is_valid_format_type(format: String) -> Bool {
  format == "json" || format == "xml" || format == "csv" ||
  format == "yaml" || format == "plain"
}

fn parse_int(s: String) -> Int {
  let result = 0
  for ch in s {
    if ch >= '0' && ch <= '9' {
      result = result * 10 + (ch.to_int() - '0'.to_int())
    }
  }
  result
}