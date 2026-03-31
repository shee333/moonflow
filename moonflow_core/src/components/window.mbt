package moonflow_core::components

pub struct WindowComponent

pub enum WindowType {
  | Tumbling
  | Sliding
  | Session
}

pub struct WindowConfig {
  window_type: WindowType
  size_ms: Int
  slide_ms: Int
}

pub fn create_window_component() -> WindowComponent {
  WindowComponent
}

pub fn create_window_config(window_type: WindowType, size_ms: Int) -> WindowConfig {
  WindowConfig::{
    window_type,
    size_ms,
    slide_ms: size_ms / 2,
  }
}

pub fn create_window_config_with_slide(
  window_type: WindowType,
  size_ms: Int,
  slide_ms: Int
) -> WindowConfig {
  WindowConfig::{
    window_type,
    size_ms,
    slide_ms,
  }
}
