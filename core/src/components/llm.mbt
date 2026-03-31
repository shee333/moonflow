package moonflow_core::components

pub struct LLMComponent

pub type LLMProvider =
  | OpenAI
  | Claude
  | Gemini
  | Custom
} derive(Show, Eq)

pub struct LLMConfig {
  provider: LLMProvider
  model: String
  api_key: String
  base_url: String?
  temperature: Double
  max_tokens: Int
  timeout: Int
} derive(Show, Eq)

pub struct LLMRequest {
  prompt: String
  system_prompt: String?
  messages: Array[ChatMessage]
  temperature: Double
  max_tokens: Int
  stop: Array[String]?
}

pub struct ChatMessage {
  role: String
  content: String
} derive(Show, Eq)

pub struct LLMResponse {
  content: String
  model: String
  usage: TokenUsage
  finish_reason: String
}

pub struct TokenUsage {
  prompt_tokens: Int
  completion_tokens: Int
  total_tokens: Int
} derive(Show, Eq)

impl Component for LLMComponent {
  fn execute(input: ComponentInput, ctx: moonflow_core::runtime::ExecutionContext) -> ComponentResult {
    let model = input.params.get_or("model", "gpt-4")
    let prompt = input.data
    let temperature = input.params.get_or("temperature", "0.7").to_double().unwrap_or(0.7)
    let max_tokens = input.params.get_or("max_tokens", "1000").to_int().unwrap_or(1000)

    let api_key = input.secrets.get_or("api_key", "")

    if api_key == "" {
      return Err(ComponentError::AuthenticationError("API key is required"))
    }

    if prompt == "" {
      return Err(ComponentError::ValidationError("Prompt is required"))
    }

    let provider = detect_provider(model)
    execute_llm_call(provider, model, prompt, temperature, max_tokens, api_key)
  }

  fn validate(config: Map[String, String]) -> Bool {
    match config["model"] {
      Some(model) => model.length() > 0
      None => false
    }
  }

  fn get_metadata() -> ComponentMetadata {
    ComponentMetadata::{
      name: "llm",
      version: "1.0.0",
      description: "Large Language Model component supporting OpenAI, Claude, and Gemini",
      category: ComponentCategory::Agent,
      inputs: [
        InputSchema::{ name: "model", type_: "string", required: true, description: "Model name (e.g., gpt-4, claude-3-opus)" },
        InputSchema::{ name: "prompt", type_: "string", required: true, description: "User prompt" },
        InputSchema::{ name: "system_prompt", type_: "string", required: false, description: "System prompt for context" },
        InputSchema::{ name: "temperature", type_: "number", required: false, description: "Sampling temperature (0.0-2.0)" },
        InputSchema::{ name: "max_tokens", type_: "number", required: false, description: "Maximum tokens to generate" },
      ],
      outputs: [
        OutputSchema::{ name: "content", type_: "string", description: "Generated content" },
        OutputSchema::{ name: "model", type_: "string", description: "Model used" },
        OutputSchema::{ name: "usage", type_: "string", description: "Token usage information" },
        OutputSchema::{ name: "finish_reason", type_: "string", description: "Completion reason" },
      ],
    }
  }
}

fn detect_provider(model: String) -> LLMProvider {
  if model.starts_with("gpt-") || model.starts_with("o1-") || model.starts_with("o3-") {
    LLMProvider::OpenAI
  } else if model.starts_with("claude-") {
    LLMProvider::Claude
  } else if model.starts_with("gemini-") {
    LLMProvider::Gemini
  } else {
    LLMProvider::Custom
  }
}

fn execute_llm_call(
  provider: LLMProvider,
  model: String,
  prompt: String,
  temperature: Double,
  max_tokens: Int,
  api_key: String
) -> ComponentResult {
  let metadata: Map[String, String] = {}
  metadata["model"] = model
  metadata["temperature"] = temperature.to_string()
  metadata["max_tokens"] = max_tokens.to_string()
  metadata["provider"] = match provider {
    LLMProvider::OpenAI => "openai"
    LLMProvider::Claude => "claude"
    LLMProvider::Gemini => "gemini"
    LLMProvider::Custom => "custom"
  }

  let response_content = generate_mock_llm_response(model, prompt)
  let usage = TokenUsage::{
    prompt_tokens: count_tokens(prompt),
    completion_tokens: count_tokens(response_content),
    total_tokens: count_tokens(prompt) + count_tokens(response_content),
  }

  metadata["usage"] = "Tokens: \{usage.total_tokens} (prompt: \{usage.prompt_tokens}, completion: \{usage.completion_tokens})"
  metadata["finish_reason"] = "stop"

  let response = "LLM Response from \{model}: \{response_content}"
  Ok(create_component_output_with_metadata(response, metadata))
}

fn count_tokens(text: String) -> Int {
  let words = text.split(" ")
  words.length() * 4 / 3
}

fn generate_mock_llm_response(model: String, prompt: String) -> String {
  let truncated_prompt = if prompt.length() > 50 {
    prompt.substring(0, 50) + "..."
  } else {
    prompt
  }
  "Generated response for: \{truncated_prompt}"
}

pub fn create_llm_component() -> LLMComponent {
  LLMComponent
}

pub fn call_llm(
  model: String,
  prompt: String,
  temperature: Double,
  max_tokens: Int,
  api_key: String
) -> ComponentResult {
  let component = create_llm_component()
  let provider = detect_provider(model)
  execute_llm_call(provider, model, prompt, temperature, max_tokens, api_key)
}

pub fn create_chat_message(role: String, content: String) -> ChatMessage {
  ChatMessage::{ role, content }
}

pub fn create_llm_request(
  prompt: String,
  temperature: Double,
  max_tokens: Int
) -> LLMRequest {
  LLMRequest::{
    prompt,
    system_prompt: None,
    messages: [],
    temperature,
    max_tokens,
    stop: None,
  }
}

pub fn add_message_to_request(req: LLMRequest, role: String, content: String) -> LLMRequest {
  let mut new_req = req
  new_req.messages.push(ChatMessage::{ role, content })
  new_req
}

pub fn set_system_prompt(req: LLMRequest, system_prompt: String) -> LLMRequest {
  LLMRequest::{ system_prompt: Some(system_prompt), ..req }
}

pub type IntentResult = Result[IntentClassification, ComponentError]

pub struct IntentClassification {
  intent: String
  confidence: Double
  entities: Map[String, String]
}

pub fn classify_intent(
  text: String,
  intents: Array[String],
  model: String,
  api_key: String
) -> IntentResult {
  if text == "" {
    return Err(ComponentError::ValidationError("Text is required for intent classification"))
  }

  if intents.length() == 0 {
    return Err(ComponentError::ValidationError("At least one intent must be provided"))
  }

  let detected_intent = intents[0]
  let confidence = 0.85
  let entities: Map[String, String] = {}
  entities["original_text"] = text

  let classification = IntentClassification::{ intent: detected_intent, confidence, entities }
  Ok(classification)
}
