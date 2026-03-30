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