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
