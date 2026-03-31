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

  fn validate(config: Map[String, String]) -> Bool {
    match config["parallel"] {
      Some(_) => true
      None => true
    }
  }

  fn get_metadata() -> ComponentMetadata {
    ComponentMetadata::{
      name: "pipeline",
      version: "1.0.0",
      description: "Pipeline orchestration component for sequential and parallel processing",
      category: ComponentCategory::Flow,
      inputs: [
        InputSchema::{ name: "parallel", type_: "boolean", required: false, description: "Enable parallel execution" },
        InputSchema::{ name: "data", type_: "string", required: true, description: "Pipeline input data" },
      ],
      outputs: [
        OutputSchema::{ name: "result", type_: "string", description: "Pipeline output" },
        OutputSchema::{ name: "stages", type_: "number", description: "Number of stages" },
      ],
    }
  }
}