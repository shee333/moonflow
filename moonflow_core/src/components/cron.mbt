package moonflow_core::components

pub struct CronComponent

pub enum CronScheduleType {
  | Interval
  | Cron
  | OneTime
  | Daily
  | Weekly
}

pub struct CronConfig {
  schedule_type: CronScheduleType
  expression: String
  timezone: String
  enabled: Bool
  max_runs: Int
}

pub fn create_cron_component() -> CronComponent {
  CronComponent
}

pub fn create_cron_config(schedule_type: CronScheduleType, expression: String) -> CronConfig {
  CronConfig::{
    schedule_type,
    expression,
    timezone: "UTC",
    enabled: true,
    max_runs: 0,
  }
}

pub fn create_cron_config_with_timezone(
  schedule_type: CronScheduleType,
  expression: String,
  timezone: String
) -> CronConfig {
  CronConfig::{
    schedule_type,
    expression,
    timezone,
    enabled: true,
    max_runs: 0,
  }
}