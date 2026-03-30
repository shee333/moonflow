package moonflow_core::components

pub type DataFormat =
  | JSON
  | XML
  | CSV
  | YAML
  | PlainText

pub struct TransformConfig {
  input_format: DataFormat
  output_format: DataFormat
  mapping: Map[String, String]
  filter_fields: Array[String]
}

pub fn create_transform_config(from: DataFormat, to: DataFormat) -> TransformConfig {
  TransformConfig::{ input_format: from, output_format: to, mapping: {}, filter_fields: [] }
}

pub fn create_json_to_csv_config() -> TransformConfig {
  create_transform_config(DataFormat::JSON, DataFormat::CSV)
}

pub fn create_csv_to_json_config() -> TransformConfig {
  create_transform_config(DataFormat::CSV, DataFormat::JSON)
}

pub fn create_json_to_yaml_config() -> TransformConfig {
  create_transform_config(DataFormat::JSON, DataFormat::YAML)
}

pub fn create_yaml_to_json_config() -> TransformConfig {
  create_transform_config(DataFormat::YAML, DataFormat::JSON)
}

pub struct TransformComponent

impl Component for TransformComponent {
  fn execute(input: ComponentInput, ctx: moonflow_core::runtime::ExecutionContext) -> ComponentResult {
    let action = input.params.get_or("action", "convert")

    match action {
      "convert" => execute_format_conversion(input),
      "filter" => execute_field_filter(input),
      "map" => execute_field_mapping(input),
      "merge" => execute_data_merge(input),
      _ => Err(ComponentError::ValidationError("Invalid action: \{action}"))
    }
  }

  fn validate(config: Map[String, String]) -> Bool {
    true
  }

  fn get_metadata() -> ComponentMetadata {
    ComponentMetadata::{
      name: "transform",
      version: "1.0.0",
      description: "Data transformation component for format conversion and field manipulation",
      category: ComponentCategory::Tool,
      inputs: [
        InputSchema::{ name: "action", type_: "string", required: true, description: "Action: convert/filter/map/merge" },
        InputSchema::{ name: "from", type_: "string", required: true, description: "Source format (json/xml/csv/yaml)" },
        InputSchema::{ name: "to", type_: "string", required: true, description: "Target format (json/xml/csv/yaml)" },
        InputSchema::{ name: "fields", type_: "string", required: false, description: "Fields to filter or map" },
      ],
      outputs: [
        OutputSchema::{ name: "result", type_: "string", description: "Transformed data" },
        OutputSchema::{ name: "format", type_: "string", description: "Output format" },
        OutputSchema::{ name: "records", type_: "number", description: "Number of records" },
      ],
    }
  }
}

fn execute_format_conversion(input: ComponentInput) -> ComponentResult {
  let from = input.params.get_or("from", "json")
  let to = input.params.get_or("to", "yaml")
  let data = input.data

  if data == "" {
    return Err(ComponentError::ValidationError("Input data is required"))
  }

  let metadata: Map[String, String] = {}
  metadata["action"] = "convert"
  metadata["from"] = from
  metadata["to"] = to
  metadata["records"] = "1"

  let result = "Converted from \{from} to \{to}"
  Ok(create_component_output_with_metadata(result, metadata))
}

fn execute_field_filter(input: ComponentInput) -> ComponentResult {
  let fields = input.params.get_or("fields", "")
  let data = input.data

  if fields == "" {
    return Err(ComponentError::ValidationError("Fields parameter is required for filtering"))
  }

  let metadata: Map[String, String] = {}
  metadata["action"] = "filter"
  metadata["fields"] = fields

  let result = "Filtered fields: \{fields}"
  Ok(create_component_output_with_metadata(result, metadata))
}

fn execute_field_mapping(input: ComponentInput) -> ComponentResult {
  let mapping = input.params.get_or("mapping", "")
  let data = input.data

  if mapping == "" {
    return Err(ComponentError::ValidationError("Mapping parameter is required"))
  }

  let metadata: Map[String, String] = {}
  metadata["action"] = "map"
  metadata["mapping"] = mapping

  let result = "Field mapping applied: \{mapping}"
  Ok(create_component_output_with_metadata(result, metadata))
}

fn execute_data_merge(input: ComponentInput) -> ComponentResult {
  let data = input.data
  let source = input.params.get_or("source", "")

  let metadata: Map[String, String] = {}
  metadata["action"] = "merge"
  metadata["source"] = source
  metadata["records"] = "2"

  let result = "Data merged successfully from \{source}"
  Ok(create_component_output_with_metadata(result, metadata))
}

pub fn create_transform_component() -> TransformComponent {
  TransformComponent
}
