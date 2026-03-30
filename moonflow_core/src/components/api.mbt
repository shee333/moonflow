package moonflow_core::components

pub struct ApiComponent

pub enum ApiAuthType {
  | None
  | Basic
  | Bearer
  | OAuth2
  | ApiKey
}

pub struct ApiConfig {
  base_url: String
  auth_type: ApiAuthType
  auth_token: String?
  timeout: Int
  rate_limit: Int
  retry_count: Int
}

pub fn create_api_component() -> ApiComponent {
  ApiComponent
}

pub fn create_api_config(base_url: String, auth_type: ApiAuthType) -> ApiConfig {
  ApiConfig::{
    base_url,
    auth_type,
    auth_token: None,
    timeout: 30,
    rate_limit: 100,
    retry_count: 3,
  }
}

pub fn create_api_config_with_token(
  base_url: String,
  auth_type: ApiAuthType,
  token: String
) -> ApiConfig {
  ApiConfig::{
    base_url,
    auth_type,
    auth_token: Some(token),
    timeout: 30,
    rate_limit: 100,
    retry_count: 3,
  }
}