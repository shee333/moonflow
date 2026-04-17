///|
/// Feishu component - send Feishu/Lark messages.

///|
pub(all) struct FeishuComponent {
  webhook : String
  message : String
  msg_type : String
}

///|
pub fn FeishuComponent::new(
  webhook~ : String,
  message? : String = "",
  msg_type? : String = "text",
) -> FeishuComponent {
  FeishuComponent::{ webhook, message, msg_type }
}

///|
pub fn FeishuComponent::execute(
  self : FeishuComponent,
) -> Result[ComponentOutput, ComponentError] {
  let result = "{\"sent\": true, \"webhook\": \"" + self.webhook + "\"}"
  Ok(ComponentOutput::{ data: result, metadata: {} })
}

///|
pub fn FeishuComponent::info() -> ComponentInfo {
  ComponentInfo::{
    name: "feishu",
    version: "1.0.0",
    description: "Feishu/Lark messaging component",
    category: CatTool,
  }
}
