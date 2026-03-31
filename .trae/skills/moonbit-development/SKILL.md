---
name: "moonbit-development"
description: "MoonBit development guide for MoonFlow workflow orchestration platform. Invoke when writing/reading MoonBit code or creating new workflow components."
---

# MoonBit Development Guide for MoonFlow

## Overview

MoonFlow is an AI Agent workflow orchestration platform built with MoonBit. This guide covers the language basics, project structure, and best practices for developing workflow components.

## Project Structure

```
moonflow/
├── core/                      # MoonBit backend
│   ├── src/
│   │   ├── components/        # 30+ workflow components
│   │   ├── runtime/          # Execution engine
│   │   ├── workflow/         # Parser & validator
│   │   └── demo/             # Demo code
│   ├── examples/              # DSL examples
│   └── tests/                # Test cases
└── frontend/                  # React frontend
```

## MoonBit Basics

### Package Declaration

```moonbit
package moonflow_core::components
```

### Data Types

#### Struct (数据结构体)

```moonbit
pub struct LLMConfig {
  provider: LLMProvider
  model: String
  api_key: String
  temperature: Double
  max_tokens: Int
}
```

#### Enum (枚举类型)

```moonbit
pub enum ComponentCategory {
  | Trigger
  | Tool
  | Agent
  | Control
}

pub type ComponentError =
  | NetworkError(String)
  | AuthenticationError(String)
  | ValidationError(String)
  | ExecutionError(String)
```

#### Trait (接口定义)

```moonbit
pub trait Component {
  fn execute(input: ComponentInput, ctx: ExecutionContext) -> ComponentResult
  fn validate(config: Map[String, String]) -> Bool
  fn get_metadata() -> ComponentMetadata
}
```

### Functions

```moonbit
pub fn create_component_output(data: String) -> ComponentOutput {
  ComponentOutput::{ data, metadata: {} }
}

pub fn format_component_error(error: ComponentError) -> String {
  match error {
    ComponentError::NetworkError(msg) => "Network error: \{msg}"
    ComponentError::ValidationError(msg) => "Validation error: \{msg}"
    _ => "Unknown error"
  }
}
```

### Implementation

```moonbit
impl Component for LLMComponent {
  fn execute(input: ComponentInput, ctx: ExecutionContext) -> ComponentResult {
    let model = input.params.get_or("model", "gpt-4")
    let prompt = input.data

    if prompt == "" {
      return Err(ComponentError::ValidationError("Prompt is required"))
    }

    Ok(ComponentOutput::{ data: "result", metadata: {} })
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
      description: "LLM component",
      category: ComponentCategory::Agent,
      inputs: [],
      outputs: []
    }
  }
}
```

## Component Development Pattern

### Standard Component Template

```moonbit
package moonflow_core::components

pub struct MyComponent

pub struct MyConfig {
  param1: String
  param2: Int
  required_field: String
}

impl Component for MyComponent {
  fn execute(input: ComponentInput, ctx: ExecutionContext) -> ComponentResult {
    // 1. Extract parameters
    let config_value = input.params.get_or("config", "{}")
    let data = input.data

    // 2. Validate input
    if data == "" {
      return Err(ComponentError::ValidationError("Data is required"))
    }

    // 3. Process logic
    let result = process_data(data)

    // 4. Return output
    Ok(ComponentOutput::{ data: result, metadata: {} })
  }

  fn validate(config: Map[String, String]) -> Bool {
    match config["required_field"] {
      Some(field) => field.length() > 0
      None => false
    }
  }

  fn get_metadata() -> ComponentMetadata {
    ComponentMetadata::{
      name: "my_component",
      version: "1.0.0",
      description: "Description of what this component does",
      category: ComponentCategory::Tool,
      inputs: [
        InputSchema::{ name: "data", type_: "string", required: true, description: "Input data" }
      ],
      outputs: [
        OutputSchema::{ name: "result", type_: "string", description: "Processing result" }
      ]
    }
  }
}
```

### Error Handling

```moonbit
fn process_with_error_handling(input: String) -> ComponentResult {
  match parse_input(input) {
    Ok(parsed) => {
      match execute_process(parsed) {
        Ok(result) => Ok(ComponentOutput::{ data: result, metadata: {} })
        Err(e) => Err(ComponentError::ExecutionError("Process failed: \{e}"))
      }
    }
    Err(e) => Err(ComponentError::ValidationError("Invalid input: \{e}"))
  }
}
```

## Coding Standards

### Naming Conventions

- **Struct/Enum/Trait**: `PascalCase` (e.g., `LLMComponent`, `ComponentError`)
- **Functions/Methods**: `snake_case` (e.g., `create_component_output`, `get_metadata`)
- **Variables**: `snake_case` (e.g., `api_key`, `max_tokens`)
- **Constants**: `SCREAMING_SNAKE_CASE` (e.g., `MAX_RETRY_COUNT`)

### Visibility

- Use `pub` for public APIs
- Omit keyword for package-private (default)
- Never use `priv` unless explicitly needed

### Documentation

```moonbit
/// Creates a new component output with data and empty metadata
/// - `data`: The output data as string
/// - returns: ComponentOutput with data and empty metadata map
pub fn create_component_output(data: String) -> ComponentOutput {
  ComponentOutput::{ data, metadata: {} }
}
```

## Workflow Integration

### Register Component

After creating a component, register it in the registry:

```moonbit
// In registry.mbt
pub fn register_all_components() {
  Registry::register("my_component", MyComponent::new)
  Registry::register("llm", LLMComponent::new)
  // ... other components
}
```

### Frontend Integration

For new components, update the frontend code generator:

```typescript
// In frontend/src/utils/codeGenerator.ts
const COMPONENT_DEFINITIONS = {
  'my_component': {
    label: 'My Component',
    category: 'tool',
    icon: '🔧',
    description: 'Component description',
    configFields: [
      { name: 'param1', type: 'string', required: true }
    ]
  }
}
```

## Testing

```moonbit
test "my component validation" {
  let config = {"required_field": "value"}
  let component = MyComponent::new()
  assert_eq(component.validate(config), true)

  let empty_config = {}
  assert_eq(component.validate(empty_config), false)
}

test "my component execution" {
  let input = ComponentInput::{
    data: "test data",
    params: {"config": "{}"},
    secrets: {}
  }
  let ctx = ExecutionContext::new()
  let result = MyComponent::execute(input, ctx)
  match result {
    Ok(output) => assert_eq(output.data.length() > 0, true)
    Err(_) => @assert.Fail::error("Expected success")
  }
}
```

## Common Patterns

### Configuration Parsing

```moonbit
fn parse_llm_config(params: Map[String, String]) -> LLMConfig {
  let model = params.get_or("model", "gpt-4")
  let temperature = params.get_or("temperature", "0.7").to_double().unwrap_or(0.7)
  let max_tokens = params.get_or("max_tokens", "1000").to_int().unwrap_or(1000)

  LLMConfig::{
    model,
    temperature,
    max_tokens,
    // ...
  }
}
```

### Context Usage

```moonbit
fn execute_with_context(input: ComponentInput, ctx: ExecutionContext) -> ComponentResult {
  // Access workflow context
  let workflow_id = ctx.workflow_id
  let node_id = ctx.node_id

  // Store intermediate results
  ctx.set_variable("last_result", result)

  // Get previous node outputs
  match ctx.get_output("previous_node") {
    Some(output) => process_with_previous(output)
    None => process_without_previous()
  }
}
```

## Best Practices

1. **Always validate inputs** before processing
2. **Return meaningful errors** with context
3. **Document component metadata** for IDE integration
4. **Write tests** for all public functions
5. **Use Option/Result** instead of null values
6. **Follow naming conventions** consistently
7. **Keep functions small** and focused on single responsibility
8. **Use match expressions** for exhaustive error handling

## Quick Reference

### Common Types

```moonbit
String, Int, Double, Bool
Array[T], Map[K, V], Option[T], Result[T, E]
```

### Common Operations

```moonbit
// String
str.length(), str.to_uppercase(), str.trim()

// Array
arr.length(), arr.push(item), arr.filter(fn), arr.map(fn)

// Map
map.get_or(key, default), map.insert(key, value)

// Option
opt.unwrap_or(default), match opt { Some(v) => ..., None => ... }
```

### String Interpolation

```moonbit
let name = "World"
let greeting = "Hello, \{name}!"  // "Hello, World!"
```

---

**Created for MoonFlow Project** - AI Agent Workflow Orchestration Platform
