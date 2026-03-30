package moonflow_core::components

pub struct FilterComponent

pub enum FilterCondition {
  | Equals
  | NotEquals
  | Contains
  | StartsWith
  | EndsWith
  | Regex
  | GreaterThan
  | LessThan
}

pub struct FilterConfig {
  field: String
  condition: FilterCondition
  value: String
  case_sensitive: Bool
}

pub fn create_filter_component() -> FilterComponent {
  FilterComponent
}

pub fn create_filter_config(field: String, condition: FilterCondition, value: String) -> FilterConfig {
  FilterConfig::{
    field,
    condition,
    value,
    case_sensitive: true,
  }
}

pub fn create_case_insensitive_filter_config(
  field: String,
  condition: FilterCondition,
  value: String
) -> FilterConfig {
  FilterConfig::{
    field,
    condition,
    value,
    case_sensitive: false,
  }
}