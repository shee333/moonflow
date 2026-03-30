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
