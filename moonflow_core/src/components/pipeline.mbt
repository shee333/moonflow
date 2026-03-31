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