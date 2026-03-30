package moonflow_core::components

pub struct WebhookComponent

pub enum WebhookMethod {
  | GET
  | POST
  | PUT
  | DELETE
  | PATCH
}

pub struct WebhookConfig {
  url: String
  method: WebhookMethod
  headers: Map[String, String]
  timeout: Int
  retry_count: Int
  secret: String?
}

pub fn create_webhook_component() -> WebhookComponent {
  WebhookComponent
}

pub fn create_webhook_config(url: String, method: WebhookMethod) -> WebhookConfig {
  WebhookConfig::{
    url,
    method,
    headers: {},
    timeout: 30,
    retry_count: 3,
    secret: None,
  }
}

pub fn create_webhook_config_with_auth(
  url: String,
  method: WebhookMethod,
  secret: String
) -> WebhookConfig {
  WebhookConfig::{
    url,
    method,
    headers: {},
    timeout: 30,
    retry_count: 3,
    secret: Some(secret),
  }
}
