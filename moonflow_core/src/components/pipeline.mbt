package moonflow_core::components

pub struct PipelineComponent

pub enum PipelineStage {
  | Input
  | Transform
  | Filter
  | Output
}

pub struct PipelineConfig {
  stages: Array[PipelineStage]
  parallel: Bool
  timeout: Int
}

pub fn create_pipeline_component() -> PipelineComponent {
  PipelineComponent
}

pub fn create_pipeline_config(stages: Array[PipelineStage]) -> PipelineConfig {
  PipelineConfig::{
    stages,
    parallel: false,
    timeout: 30000,
  }
}

pub fn create_pipeline_config_with_options(
  stages: Array[PipelineStage],
  parallel: Bool,
  timeout: Int
) -> PipelineConfig {
  PipelineConfig::{
    stages,
    parallel,
    timeout,
  }
}

impl Component for PipelineComponent {
  fn execute(input: ComponentInput, ctx: moonflow_core::runtime::ExecutionContext) -> ComponentResult {
    let data = input.data
    let parallel = input.params.get_or("parallel", "false") == "true"

    if data == "" {
      return Err(ComponentError::ValidationError("Input data is required"))
    }

    execute_pipeline_operation(parallel, data)
  }