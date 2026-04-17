///|
/// MoonFlow Component System
/// Defines component types, traits, and built-in component implementations.

///|
pub(all) struct ComponentOutput {
  data : String
  metadata : Map[String, String]
}

///|
pub(all) enum ComponentError {
  NetworkError(String)
  AuthenticationError(String)
  ValidationError(String)
  ExecutionError(String)
  TimeoutError
  RateLimitError
  UnknownError(String)
} derive(Show)

///|
pub(all) struct ComponentInput {
  data : String
  params : Map[String, String]
}

///|
pub(all) enum ComponentCategory {
  CatTrigger
  CatTool
  CatAgent
  CatControl
} derive(Show, Eq)

///|
pub(all) struct ComponentInfo {
  name : String
  version : String
  description : String
  category : ComponentCategory
} derive(Show)

///|
pub fn format_component_error(err : ComponentError) -> String {
  match err {
    NetworkError(msg) => "Network error: " + msg
    AuthenticationError(msg) => "Auth error: " + msg
    ValidationError(msg) => "Validation error: " + msg
    ExecutionError(msg) => "Execution error: " + msg
    TimeoutError => "Timeout error"
    RateLimitError => "Rate limit exceeded"
    UnknownError(msg) => "Unknown error: " + msg
  }
}
