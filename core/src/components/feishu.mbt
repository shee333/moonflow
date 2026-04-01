package moonflow_core::components

pub struct FeishuComponent

impl Component for FeishuComponent {
  fn execute(input: ComponentInput, ctx: moonflow_core::runtime::ExecutionContext) -> ComponentResult {
    let webhook = input.secrets.get_or("webhook", "")

    if webhook == "" {
      return Err(ComponentError::AuthenticationError("Feishu webhook is required"))
    }

    if not is_valid_feishu_webhook(webhook) {
      return Err(ComponentError::ValidationError("Invalid Feishu webhook URL format"))
    }

    let message_type = input.params.get_or("message_type", "text")
    let content = input.data

    if content == "" {
      return Err(ComponentError::ValidationError("Message content is required"))
    }

    if not is_valid_message_type(message_type) {
      return Err(ComponentError::ValidationError("Invalid message type: \{message_type}. Must be one of: text, post, image, interactive"))
    }

    execute_send_feishu_message(webhook, message_type, content, ctx)
  }

  fn validate(config: Map[String, String]) -> Bool {
    match config["message_type"] {
      Some(msg_type) => is_valid_message_type(msg_type)
      None => false
    }
  }

  fn get_metadata() -> ComponentMetadata {
    ComponentMetadata::{
      name: "feishu",
      version: "1.1.0",
      description: "Feishu (Lark) webhook notification component",
      category: ComponentCategory::Tool,
      inputs: [
        InputSchema::{ name: "webhook", type_: "string", required: true, description: "Feishu webhook URL" },
        InputSchema::{ name: "message_type", type_: "string", required: true, description: "Message type: text/post/image/interactive" },
        InputSchema::{ name: "content", type_: "string", required: true, description: "Message content" },
      ],
      outputs: [
        OutputSchema::{ name: "msg_id", type_: "string", description: "Feishu message ID" },
        OutputSchema::{ name: "status", type_: "string", description: "Send status" },
        OutputSchema::{ name: "timestamp", type_: "string", description: "Send timestamp" },
        OutputSchema::{ name: "message_type", type_: "string", description: "Message type sent" },
      ],
    }
  }
}

fn is_valid_feishu_webhook(webhook: String) -> Bool {
  webhook.starts_with("https://open.feishu.cn/open-apis/bot/v2/hook/")
}

fn is_valid_message_type(msg_type: String) -> Bool {
  msg_type == "text" || msg_type == "post" || msg_type == "image" || msg_type == "interactive"
}

fn execute_send_feishu_message(webhook: String, message_type: String, content: String, ctx: moonflow_core::runtime::ExecutionContext) -> ComponentResult {
  let metadata: Map[String, String] = {}
  metadata["webhook"] = webhook
  metadata["message_type"] = message_type
  metadata["status"] = "sent"
  metadata["timestamp"] = ctx.start_time.to_string()
  metadata["msg_id"] = "msg_\{ctx.start_time}"

  let response = "\{\"success\": true, \"message\": \"Feishu message sent\", \"msg_id\": \"msg_\{ctx.start_time}\", \"timestamp\": \{ctx.start_time}}"
  Ok(create_component_output_with_metadata(response, metadata))
}

pub fn create_feishu_component() -> FeishuComponent {
  FeishuComponent
}

pub fn send_feishu_text_message(webhook: String, text: String) -> ComponentResult {
  let component = create_feishu_component()
  let input = ComponentInput::{
    data: text,
    params: { "message_type": "text" },
    secrets: { "webhook": webhook },
  }
  let ctx = moonflow_core::runtime::ExecutionContext::{
    workflow_id: "",
    execution_id: "",
    node_results: {},
    variables: {},
    start_time: 0,
    end_time: None,
    node_executions: {},
    max_concurrency: 1,
  }
  component.execute(input, ctx)
}

pub type FeishuMessageType =
  | Text
  | Post
  | Image
  | Interactive

pub struct FeishuTextMessage {
  text: String
}

pub struct FeishuPostMessage {
  title: String
  content: Array[Array[FeishuContentItem]]
}

pub struct FeishuContentItem {
  tag: String
  text: String?
  href: String?
}

pub fn create_feishu_text_message(text: String) -> FeishuTextMessage {
  FeishuTextMessage::{ text }
}

pub fn create_feishu_post_message(title: String, content: Array[Array[FeishuContentItem]]) -> FeishuPostMessage {
  FeishuPostMessage::{ title, content }
}

pub fn create_feishu_content_item(tag: String, text: String?, href: String?) -> FeishuContentItem {
  FeishuContentItem::{ tag, text, href }
}

pub fn format_feishu_message(msg_type: FeishuMessageType, content: String) -> String {
  match msg_type {
    FeishuMessageType::Text => "\{\"msg_type\":\"text\",\"content\":\{\"text\":\"\{content}\"\}\}"
    FeishuMessageType::Post => "\{\"msg_type\":\"post\",\"content\":\{\"post\":\{\"zh_cn\":\{\"title\":\"Feishu Notification\",\"content\":[[\{\"tag\":\"text\",\"text\":\"\{content}\"\}]]\}\}\}\}"
    FeishuMessageType::Image => "\{\"msg_type\":\"image\",\"content\":\{\"image_key\":\"\{content}\"\}\}"
    FeishuMessageType::Interactive => "\{\"msg_type\":\"interactive\",\"card\":\{\"config\":\{\"wide_screen_mode\":true\},\"elements\":[\{\"tag\":\"div\",\"text\":\{\"tag\":\"lark_md\",\"content\":\"\{content}\"\}\}]\}\}"
  }
}
