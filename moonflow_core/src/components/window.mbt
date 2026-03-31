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
