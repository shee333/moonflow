///|
/// Scheduler - placeholder for advanced scheduling logic.
/// Currently execution order is computed by workflow_helpers.get_execution_order().

///|
pub(all) struct SchedulerConfig {
  max_parallel : Int
  timeout_ms : Int
}

///|
pub fn SchedulerConfig::default() -> SchedulerConfig {
  SchedulerConfig::{ max_parallel: 1, timeout_ms: 30000 }
}
