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

impl Component for FilterComponent {
  fn execute(input: ComponentInput, ctx: moonflow_core::runtime::ExecutionContext) -> ComponentResult {
    let field = input.params.get_or("field", "")
    let condition = input.params.get_or("condition", "equals")
    let value = input.params.get_or("value", "")
    let data = input.data

    if field == "" {
      return Err(ComponentError::ValidationError("Filter field is required"))
    }

    let case_sensitive = match input.params["case_sensitive"] {
      Some(cs) => cs == "true"
      None => true
    }

    execute_filter_operation(field, condition, value, data, case_sensitive)
  }

  fn validate(config: Map[String, String]) -> Bool {
    match (config["field"], config["condition"]) {
      (Some(field_name), Some(cond)) =>
        field_name.length() > 0 && is_valid_filter_condition(cond)
      _ => false
    }
  }

  fn get_metadata() -> ComponentMetadata {
    ComponentMetadata::{
      name: "filter",
      version: "1.0.0",
      description: "Data filtering component with multiple condition types",
      category: ComponentCategory::Tool,
      inputs: [
        InputSchema::{ name: "field", type_: "string", required: true, description: "Field name to filter on" },
        InputSchema::{ name: "condition", type_: "string", required: true, description: "Filter condition: equals/not_equals/contains/starts_with/ends_with/regex/gt/lt" },
        InputSchema::{ name: "value", type_: "string", required: true, description: "Value to compare against" },
        InputSchema::{ name: "case_sensitive", type_: "boolean", required: false, description: "Case sensitive matching" },
        InputSchema::{ name: "data", type_: "string", required: true, description: "Data to filter" },
      ],
      outputs: [
        OutputSchema::{ name: "passed", type_: "boolean", description: "Whether data passed the filter" },
        OutputSchema::{ name: "field", type_: "string", description: "Field filtered on" },
        OutputSchema::{ name: "condition", type_: "string", description: "Condition applied" },
      ],
    }
  }
}

fn execute_filter_operation(
  field: String,
  condition: String,
  value: String,
  data: String,
  case_sensitive: Bool
) -> ComponentResult {
  let metadata: Map[String, String] = {}
  metadata["field"] = field
  metadata["condition"] = condition
  metadata["value"] = value
  metadata["case_sensitive"] = case_sensitive.to_string()
  metadata["status"] = "filtered"

  let passed = apply_filter_condition(condition, value, data, case_sensitive)
  metadata["passed"] = passed.to_string()

  let response = "Filter on '\{field}' with '\{condition}' for '\{value}': \{if passed { "passed" } else { "rejected" }}"
  Ok(create_component_output_with_metadata(response, metadata))
}

fn apply_filter_condition(condition: String, value: String, data: String, case_sensitive: Bool) -> Bool {
  let data_cmp = if case_sensitive { data } else { data.to_upper() }
  let value_cmp = if case_sensitive { value } else { value.to_upper() }

  match condition {
    "equals" => data_cmp == value_cmp
    "not_equals" => data_cmp != value_cmp
    "contains" => data_cmp.contains(value_cmp)
    "starts_with" => data_cmp.starts_with(value_cmp)
    "ends_with" => data_cmp.ends_with(value_cmp)
    _ => true
  }
}

fn is_valid_filter_condition(condition: String) -> Bool {
  condition == "equals" || condition == "not_equals" ||
  condition == "contains" || condition == "starts_with" ||
  condition == "ends_with" || condition == "regex" ||
  condition == "gt" || condition == "lt"
}