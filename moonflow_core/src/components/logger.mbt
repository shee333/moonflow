package moonflow_core::components

pub struct LoggerComponent

pub enum LogLevel {
  | Debug
  | Info
  | Warning
  | Error
  | Critical
}

pub enum LogTarget {
  | Console
  | File
  | Syslog
  | Http
}

pub struct LogConfig {
  level: LogLevel
  targets: Array[LogTarget]
  format: String
  include_timestamp: Bool
  include_caller: Bool
  max_file_size: Int
  rotation_size: Int
}

pub fn create_logger_component() -> LoggerComponent {
  LoggerComponent
}

pub fn create_log_config(level: LogLevel, targets: Array[LogTarget]) -> LogConfig {
  LogConfig::{
    level,
    targets,
    format: "json",
    include_timestamp: true,
    include_caller: false,
    max_file_size: 10485760,
    rotation_size: 5,
  }
}

pub fn create_log_config_with_format(level: LogLevel, targets: Array[LogTarget], format: String) -> LogConfig {
  LogConfig::{
    level,
    targets,
    format,
    include_timestamp: true,
    include_caller: false,
    max_file_size: 10485760,
    rotation_size: 5,
  }
}

impl Component for LoggerComponent {
  fn execute(input: ComponentInput, ctx: moonflow_core::runtime::ExecutionContext) -> ComponentResult {
    let level_str = input.params.get_or("level", "info")
    let message = input.data
    let target_str = input.params.get_or("target", "console")

    if message == "" {
      return Err(ComponentError::ValidationError("Log message is required"))
    }

    let level = parse_log_level(level_str)
    let target = parse_log_target(target_str)

    execute_log_message(level, target, message, ctx.workflow_id, ctx.execution_id)
  }

  fn validate(config: Map[String, String]) -> Bool {
    match (config["message"], config["level"]) {
      (Some(msg), Some(level)) => msg.length() > 0 && is_valid_log_level(level)
      _ => false
    }
  }

  fn get_metadata() -> ComponentMetadata {
    ComponentMetadata::{
      name: "logger",
      version: "1.0.0",
      description: "Logging component with multiple log levels and output targets",
      category: ComponentCategory::Tool,
      inputs: [
        InputSchema::{ name: "level", type_: "string", required: true, description: "Log level: debug/info/warning/error/critical" },
        InputSchema::{ name: "message", type_: "string", required: true, description: "Log message content" },
        InputSchema::{ name: "target", type_: "string", required: false, description: "Log target: console/file/syslog/http" },
        InputSchema::{ name: "format", type_: "string", required: false, description: "Log format: json/text" },
      ],
      outputs: [
        OutputSchema::{ name: "timestamp", type_: "string", description: "Log timestamp" },
        OutputSchema::{ name: "level", type_: "string", description: "Log level" },
        OutputSchema::{ name: "status", type_: "string", description: "Log status" },
      ],
    }
  }
}

fn parse_log_level(level: String) -> LogLevel {
  match level {
    "debug" => LogLevel::Debug
    "info" => LogLevel::Info
    "warning" => LogLevel::Warning
    "error" => LogLevel::Error
    "critical" => LogLevel::Critical
    _ => LogLevel::Info
  }
}

fn parse_log_target(target: String) -> LogTarget {
  match target {
    "file" => LogTarget::File
    "syslog" => LogTarget::Syslog
    "http" => LogTarget::Http
    _ => LogTarget::Console
  }
}

fn is_valid_log_level(level: String) -> Bool {
  level == "debug" || level == "info" || level == "warning" || level == "error" || level == "critical"
}

fn execute_log_message(
  level: LogLevel,
  target: LogTarget,
  message: String,
  workflow_id: String,
  execution_id: String
) -> ComponentResult {
  let metadata: Map[String, String] = {}
  metadata["level"] = format_log_level(level)
  metadata["target"] = format_log_target(target)
  metadata["workflow_id"] = workflow_id
  metadata["execution_id"] = execution_id
  metadata["status"] = "logged"

  let response = "[\{format_log_level(level)}] Logged to \{format_log_target(target)}: \{message}"
  Ok(create_component_output_with_metadata(response, metadata))
}

fn format_log_level(level: LogLevel) -> String {
  match level {
    LogLevel::Debug => "DEBUG"
    LogLevel::Info => "INFO"
    LogLevel::Warning => "WARNING"
    LogLevel::Error => "ERROR"
    LogLevel::Critical => "CRITICAL"
  }
}

fn format_log_target(target: LogTarget) -> String {
  match target {
    LogTarget::Console => "console"
    LogTarget::File => "file"
    LogTarget::Syslog => "syslog"
    LogTarget::Http => "http"
  }
}

pub fn format_log_message(level: LogLevel, message: String, include_timestamp: Bool) -> String {
  let timestamp = if include_timestamp { "2024-01-01 00:00:00" } else { "" }
  let level_str = format_log_level(level)
  if include_timestamp {
    "[\{timestamp}] [\{level_str}] \{message}"
  } else {
    "[\{level_str}] \{message}"
  }
}
