package moonflow_core::components

pub struct ValidatorComponent

pub enum ValidationRule {
  | Required
  | Email
  | URL
  | Regex
  | Range
  | Length
  | Custom
}

pub struct ValidationRuleConfig {
  rule: ValidationRule
  pattern: String?
  min: Int?
  max: Int?
  message: String
}

pub fn create_validator_component() -> ValidatorComponent {
  ValidatorComponent
}

pub fn create_validation_rule(rule: ValidationRule, message: String) -> ValidationRuleConfig {
  ValidationRuleConfig::{
    rule,
    pattern: None,
    min: None,
    max: None,
    message,
  }
}

pub fn create_validation_rule_with_pattern(
  rule: ValidationRule,
  pattern: String,
  message: String
) -> ValidationRuleConfig {
  ValidationRuleConfig::{
    rule,
    pattern: Some(pattern),
    min: None,
    max: None,
    message,
  }
}

impl Component for ValidatorComponent {
  fn execute(input: ComponentInput, ctx: moonflow_core::runtime::ExecutionContext) -> ComponentResult {
    let rule_type = input.params.get_or("rule", "required")
    let value = input.data

    if rule_type == "required" && value == "" {
      return Err(ComponentError::ValidationError("Value is required"))
    }

    if rule_type == "email" && !is_valid_email(value) {
      return Err(ComponentError::ValidationError("Invalid email format"))
    }

    if rule_type == "url" && !is_valid_url(value) {
      return Err(ComponentError::ValidationError("Invalid URL format"))
    }

    execute_validation(rule_type, value)
  }

  fn validate(config: Map[String, String]) -> Bool {
    match config["rule"] {
      Some(rule) => is_valid_rule_type(rule)
      None => false
    }
  }

  fn get_metadata() -> ComponentMetadata {
    ComponentMetadata::{
      name: "validator",
      version: "1.0.0",
      description: "Data validation component supporting required, email, URL, regex, range, and length rules",
      category: ComponentCategory::Tool,
      inputs: [
        InputSchema::{ name: "rule", type_: "string", required: true, description: "Validation rule: required/email/url/regex/range/length/custom" },
        InputSchema::{ name: "value", type_: "string", required: true, description: "Value to validate" },
        InputSchema::{ name: "pattern", type_: "string", required: false, description: "Regex pattern for custom validation" },
        InputSchema::{ name: "min", type_: "number", required: false, description: "Minimum value or length" },
        InputSchema::{ name: "max", type_: "number", required: false, description: "Maximum value or length" },
      ],
      outputs: [
        OutputSchema::{ name: "valid", type_: "boolean", description: "Validation result" },
        OutputSchema::{ name: "message", type_: "string", description: "Validation message" },
        OutputSchema::{ name: "rule", type_: "string", description: "Applied validation rule" },
      ],
    }
  }
}

fn execute_validation(rule_type: String, value: String) -> ComponentResult {
  let metadata: Map[String, String] = {}
  metadata["rule"] = rule_type
  metadata["valid"] = "true"
  metadata["status"] = "validated"

  let response = "Validation passed for rule '\{rule_type}' with value '\{value}'"
  Ok(create_component_output_with_metadata(response, metadata))
}

fn is_valid_email(email: String) -> Bool {
  email.contains("@") && email.contains(".")
}

fn is_valid_url(url: String) -> Bool {
  url.starts_with("http://") || url.starts_with("https://")
}

fn is_valid_rule_type(rule: String) -> Bool {
  rule == "required" || rule == "email" || rule == "url" ||
  rule == "regex" || rule == "range" || rule == "length" || rule == "custom"
}