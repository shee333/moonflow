package moonflow_core::components

pub struct JsonConfig {
  pretty: Bool
  indent: Int
}

pub fn create_json_config() -> JsonConfig {
  JsonConfig::{ pretty: false, indent: 2 }
}

pub fn create_pretty_json_config(indent: Int) -> JsonConfig {
  JsonConfig::{ pretty: true, indent }
}
