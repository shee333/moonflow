///|
/// LLM component - Large Language Model integration.

///|
pub(all) struct LlmComponent {
  model : String
  provider : String
  prompt : String
  temperature : Double
  max_tokens : Int
}

///|
pub fn LlmComponent::new(
  model? : String = "gpt-4",
  provider? : String = "openai",
  prompt? : String = "",
  temperature? : Double = 0.7,
  max_tokens? : Int = 1000,
) -> LlmComponent {
  LlmComponent::{ model, provider, prompt, temperature, max_tokens }
}

///|
pub fn LlmComponent::execute(
  self : LlmComponent,
) -> Result[ComponentOutput, ComponentError] {
  let response = "[MoonFlow LLM] Model: " +
    self.model +
    ", Provider: " +
    self.provider
  let meta : Map[String, String] = {}
  meta["model"] = self.model
  meta["provider"] = self.provider
  Ok(ComponentOutput::{ data: response, metadata: meta })
}

///|
pub fn LlmComponent::info() -> ComponentInfo {
  ComponentInfo::{
    name: "llm",
    version: "1.0.0",
    description: "Large Language Model component",
    category: CatAgent,
  }
}
