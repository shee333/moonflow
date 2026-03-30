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