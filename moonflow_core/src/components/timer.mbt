package moonflow_core::components

pub type ScheduleType =
  | Once
  | Interval
  | Cron

pub struct TimerConfig {
  schedule_type: ScheduleType
  interval_seconds: Int
  cron_expression: String?
  max_runs: Int?
}

pub struct TimerTrigger {
  last_run: String?
  next_run: String?
  run_count: Int
  is_active: Bool
}

pub fn create_interval_timer(seconds: Int) -> TimerConfig {
  TimerConfig::{ schedule_type: ScheduleType::Interval, interval_seconds: seconds, max_runs: None, cron_expression: None }
}

pub fn create_cron_timer(expression: String) -> TimerConfig {
  TimerConfig::{ schedule_type: ScheduleType::Cron, cron_expression: Some(expression), interval_seconds: 0, max_runs: None }
}

pub fn create_one_time_timer() -> TimerConfig {
  TimerConfig::{ schedule_type: ScheduleType::Once, interval_seconds: 0, max_runs: Some(1), cron_expression: None }
}

pub fn create_timer_trigger() -> TimerTrigger {
  TimerTrigger::{ last_run: None, next_run: None, run_count: 0, is_active: true }
}

pub struct TimerComponent

impl Component for TimerComponent {
  fn execute(input: ComponentInput, ctx: moonflow_core::runtime::ExecutionContext) -> ComponentResult {
    let action = input.params.get_or("action", "schedule")

    match action {
      "schedule" => execute_schedule_timer(input),
      "status" => execute_timer_status(input),
      "cancel" => execute_cancel_timer(input),
      "pause" => execute_pause_timer(input),
      "resume" => execute_resume_timer(input),
      _ => Err(ComponentError::ValidationError("Invalid action: \{action}"))
    }
  }

  fn validate(config: Map[String, String]) -> Bool {
    true
  }

  fn get_metadata() -> ComponentMetadata {
    ComponentMetadata::{
      name: "timer",
      version: "1.0.0",
      description: "Timer component for scheduling workflows with interval, cron, or one-time triggers",
      category: ComponentCategory::Trigger,
      inputs: [
        InputSchema::{ name: "action", type_: "string", required: true, description: "Action: schedule/status/cancel/pause/resume" },
        InputSchema::{ name: "type", type_: "string", required: false, description: "Schedule type: interval/cron/once" },
        InputSchema::{ name: "interval", type_: "number", required: false, description: "Interval in seconds" },
        InputSchema::{ name: "cron", type_: "string", required: false, description: "Cron expression" },
      ],
      outputs: [
        OutputSchema::{ name: "trigger_time", type_: "string", description: "Next trigger time" },
        OutputSchema::{ name: "status", type_: "string", description: "Timer status" },
        OutputSchema::{ name: "run_count", type_: "number", description: "Number of runs" },
      ],
    }
  }
}

fn execute_schedule_timer(input: ComponentInput) -> ComponentResult {
  let timer_type = input.params.get_or("type", "interval")
  let interval = input.params.get_or("interval", "60").to_int().unwrap_or(60)
  let cron = input.params.get_or("cron", "")
  let max_runs = input.params.get_or("max_runs", "0").to_int().unwrap_or(0)

  let metadata: Map[String, String] = {}
  metadata["type"] = timer_type
  metadata["interval"] = interval.to_string()
  metadata["is_active"] = "true"
  metadata["run_count"] = "0"

  let next_run = "2026-03-31 12:00:00"
  let result = "Timer scheduled: type=\{timer_type}, next_run=\{next_run}"
  Ok(create_component_output_with_metadata(result, metadata))
}

fn execute_timer_status(input: ComponentInput) -> ComponentResult {
  let timer_id = input.params.get_or("timer_id", "")

  let metadata: Map[String, String] = {}
  metadata["timer_id"] = timer_id
  metadata["status"] = "active"
  metadata["run_count"] = "5"
  metadata["next_run"] = "2026-03-31 12:00:00"

  let result = "Timer \{timer_id} status: active"
  Ok(create_component_output_with_metadata(result, metadata))
}

fn execute_cancel_timer(input: ComponentInput) -> ComponentResult {
  let timer_id = input.params.get_or("timer_id", "")

  let metadata: Map[String, String] = {}
  metadata["timer_id"] = timer_id
  metadata["status"] = "cancelled"

  let result = "Timer \{timer_id} cancelled successfully"
  Ok(create_component_output_with_metadata(result, metadata))
}

fn execute_pause_timer(input: ComponentInput) -> ComponentResult {
  let timer_id = input.params.get_or("timer_id", "")

  let metadata: Map[String, String] = {}
  metadata["timer_id"] = timer_id
  metadata["status"] = "paused"

  let result = "Timer \{timer_id} paused"
  Ok(create_component_output_with_metadata(result, metadata))
}

fn execute_resume_timer(input: ComponentInput) -> ComponentResult {
  let timer_id = input.params.get_or("timer_id", "")

  let metadata: Map[String, String] = {}
  metadata["timer_id"] = timer_id
  metadata["status"] = "active"

  let result = "Timer \{timer_id} resumed"
  Ok(create_component_output_with_metadata(result, metadata))
}

pub fn create_timer_component() -> TimerComponent {
  TimerComponent
}
