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
