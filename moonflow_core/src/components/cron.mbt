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

impl Component for CronComponent {
  fn execute(input: ComponentInput, ctx: moonflow_core::runtime::ExecutionContext) -> ComponentResult {
    let operation = input.params.get_or("operation", "schedule")
    let expression = input.params.get_or("expression", "")
    let timezone = input.params.get_or("timezone", "UTC")

    if expression == "" {
      return Err(ComponentError::ValidationError("Cron expression is required"))
    }

    let schedule_type = input.params.get_or("schedule_type", "cron")
    execute_cron_operation(operation, schedule_type, expression, timezone)
  }

  fn validate(config: Map[String, String]) -> Bool {
    match (config["expression"], config["schedule_type"]) {
      (Some(expr), Some(stype)) => expr.length() > 0 && is_valid_schedule_type(stype)
      _ => false
    }
  }

  fn get_metadata() -> ComponentMetadata {
    ComponentMetadata::{
      name: "cron",
      version: "1.0.0",
      description: "Cron scheduling component with interval, cron, and one-time support",
      category: ComponentCategory::Trigger,
      inputs: [
        InputSchema::{ name: "operation", type_: "string", required: true, description: "Cron operation: schedule/cancel/pause/resume" },
        InputSchema::{ name: "expression", type_: "string", required: true, description: "Cron expression or interval" },
        InputSchema::{ name: "schedule_type", type_: "string", required: false, description: "Schedule type: interval/cron/one-time/daily/weekly" },
        InputSchema::{ name: "timezone", type_: "string", required: false, description: "Timezone for scheduling" },
      ],
      outputs: [
        OutputSchema::{ name: "job_id", type_: "string", description: "Scheduled job ID" },
        OutputSchema::{ name: "next_run", type_: "string", description: "Next scheduled run time" },
        OutputSchema::{ name: "status", type_: "string", description: "Job status" },
      ],
    }
  }
}

fn execute_cron_operation(
  operation: String,
  schedule_type: String,
  expression: String,
  timezone: String
) -> ComponentResult {
  let metadata: Map[String, String] = {}
  metadata["operation"] = operation
  metadata["schedule_type"] = schedule_type
  metadata["expression"] = expression
  metadata["timezone"] = timezone
  metadata["status"] = "scheduled"

  let response = "Cron job '\{operation}' scheduled with '\{schedule_type}' expression '\{expression}' in \{timezone}"
  Ok(create_component_output_with_metadata(response, metadata))
}

fn is_valid_schedule_type(schedule_type: String) -> Bool {
  schedule_type == "interval" || schedule_type == "cron" || schedule_type == "one-time" ||
  schedule_type == "daily" || schedule_type == "weekly"
}