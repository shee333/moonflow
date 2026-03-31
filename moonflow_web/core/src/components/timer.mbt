package moonflow_core::components

pub struct TimerComponent

pub enum TimerType {
  | Interval
  | Timeout
  | Delay
}

pub struct TimerConfig {
  timer_type: TimerType
  duration_ms: Int
  repeat: Bool
  max_runs: Int
}

pub fn create_timer_component() -> TimerComponent {
  TimerComponent
}

pub fn create_timer_config(timer_type: TimerType, duration_ms: Int) -> TimerConfig {
  TimerConfig::{
    timer_type,
    duration_ms,
    repeat: false,
    max_runs: 0,
  }
}

pub fn create_repeating_timer_config(timer_type: TimerType, duration_ms: Int, max_runs: Int) -> TimerConfig {
  TimerConfig::{
    timer_type,
    duration_ms,
    repeat: true,
    max_runs,
  }
}

impl Component for TimerComponent {
  fn execute(input: ComponentInput, ctx: moonflow_core::runtime::ExecutionContext) -> ComponentResult {
    let operation = input.params.get_or("operation", "start")
    let timer_type = input.params.get_or("timer_type", "interval")
    let duration_ms = match input.params["duration_ms"] {
      Some(d) => parse_int(d)
      None => 1000
    }

    let repeat = match input.params["repeat"] {
      Some(r) => r == "true"
      None => false
    }

    execute_timer_operation(operation, timer_type, duration_ms, repeat)
  }

  fn validate(config: Map[String, String]) -> Bool {
    match (config["timer_type"], config["duration_ms"]) {
      (Some(ttype), Some(duration)) =>
        is_valid_timer_type(ttype) && parse_int(duration) > 0
      _ => false
    }
  }

  fn get_metadata() -> ComponentMetadata {
    ComponentMetadata::{
      name: "timer",
      version: "1.0.0",
      description: "Timer component supporting interval, timeout, and delay operations",
      category: ComponentCategory::Trigger,
      inputs: [
        InputSchema::{ name: "operation", type_: "string", required: true, description: "Timer operation: start/stop/pause/resume" },
        InputSchema::{ name: "timer_type", type_: "string", required: true, description: "Timer type: interval/timeout/delay" },
        InputSchema::{ name: "duration_ms", type_: "number", required: true, description: "Duration in milliseconds" },
        InputSchema::{ name: "repeat", type_: "boolean", required: false, description: "Repeat timer" },
      ],
      outputs: [
        OutputSchema::{ name: "timer_id", type_: "string", description: "Timer ID" },
        OutputSchema::{ name: "status", type_: "string", description: "Timer status" },
        OutputSchema::{ name: "next_trigger", type_: "number", description: "Next trigger timestamp" },
      ],
    }
  }
}

fn execute_timer_operation(
  operation: String,
  timer_type: String,
  duration_ms: Int,
  repeat: Bool
) -> ComponentResult {
  let metadata: Map[String, String] = {}
  metadata["operation"] = operation
  metadata["timer_type"] = timer_type
  metadata["duration_ms"] = duration_ms.to_string()
  metadata["repeat"] = repeat.to_string()
  metadata["status"] = if operation == "start" { "running" } else { "stopped" }

  let response = "Timer '\{operation}' started with type '\{timer_type}' for \{duration_ms}ms, repeat: \{repeat}"
  Ok(create_component_output_with_metadata(response, metadata))
}

fn is_valid_timer_type(timer_type: String) -> Bool {
  timer_type == "interval" || timer_type == "timeout" || timer_type == "delay"
}

fn parse_int(s: String) -> Int {
  let result = 0
  for ch in s {
    if ch >= '0' && ch <= '9' {
      result = result * 10 + (ch.to_int() - '0'.to_int())
    }
  }
  result
}