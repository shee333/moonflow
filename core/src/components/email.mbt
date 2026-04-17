///|
/// Email component - send email notifications.

///|
pub(all) struct EmailComponent {
  to : String
  subject : String
  body : String
}

///|
pub fn EmailComponent::new(
  to~ : String,
  subject? : String = "",
  body? : String = "",
) -> EmailComponent {
  EmailComponent::{ to, subject, body }
}

///|
pub fn EmailComponent::execute(
  self : EmailComponent,
) -> Result[ComponentOutput, ComponentError] {
  let result = "{\"sent\": true, \"to\": \"" + self.to + "\"}"
  Ok(ComponentOutput::{ data: result, metadata: {} })
}

///|
pub fn EmailComponent::info() -> ComponentInfo {
  ComponentInfo::{
    name: "email",
    version: "1.0.0",
    description: "Email notification component",
    category: CatTool,
  }
}
