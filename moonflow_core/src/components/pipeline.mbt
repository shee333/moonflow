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