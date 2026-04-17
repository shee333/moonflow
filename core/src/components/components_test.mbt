///|
/// Black-box tests for component system.

// ─── ComponentRegistry ───

///|
test "registry: creates with all components" {
  let reg = @components.ComponentRegistry::new()
  inspect(reg.count(), content="11")
}

///|
test "registry: get existing component" {
  let reg = @components.ComponentRegistry::new()
  guard reg.get("http") is Some(info) else { fail("expected http") }
  inspect(info.name, content="http")
  inspect(info.category, content="CatTool")
}

///|
test "registry: get missing component" {
  let reg = @components.ComponentRegistry::new()
  assert_true(reg.get("nonexistent") is None)
}

///|
test "registry: list all components" {
  let reg = @components.ComponentRegistry::new()
  let all = reg.list()
  inspect(all.length(), content="11")
}

///|
test "registry: register custom component" {
  let reg = @components.ComponentRegistry::new()
  reg.register(@components.ComponentInfo::{
    name: "custom",
    version: "1.0",
    description: "Custom",
    category: CatTool,
  })
  inspect(reg.count(), content="12")
  guard reg.get("custom") is Some(_) else { fail("expected custom") }
}

// ─── HttpComponent ───

///|
test "http component: execute with input URL" {
  let http = @components.HttpComponent::new("http://default.com")
  let input = @components.ComponentInput::{
    data: "http://override.com",
    params: {},
  }
  guard http.execute(input) is Ok(output) else { fail("expected ok") }
  assert_true(output.data.contains("http://override.com"))
}

///|
test "http component: execute with default URL" {
  let http = @components.HttpComponent::new("http://base.test")
  let input = @components.ComponentInput::{ data: "", params: {} }
  guard http.execute(input) is Ok(output) else { fail("expected ok") }
  assert_true(output.data.contains("http://base.test"))
}

///|
test "http component: info" {
  let info = @components.HttpComponent::info()
  inspect(info.name, content="http")
  inspect(info.category, content="CatTool")
}

// ─── LlmComponent ───

///|
test "llm component: default creation" {
  let llm = @components.LlmComponent::new()
  guard llm.execute() is Ok(out) else { fail("expected ok") }
  assert_true(out.data.contains("gpt-4"))
  assert_true(out.data.contains("openai"))
  inspect(out.metadata["model"], content="gpt-4")
  inspect(out.metadata["provider"], content="openai")
}

///|
test "llm component: custom model" {
  let llm = @components.LlmComponent::new(
    model="claude-3",
    provider="anthropic",
  )
  guard llm.execute() is Ok(out) else { fail("expected ok") }
  assert_true(out.data.contains("claude-3"))
  inspect(out.metadata["provider"], content="anthropic")
}

///|
test "llm component: info" {
  let info = @components.LlmComponent::info()
  inspect(info.name, content="llm")
  inspect(info.category, content="CatAgent")
}

// ─── EmailComponent ───

///|
test "email component: execute" {
  let email = @components.EmailComponent::new(
    to="user@test.com",
    subject="Hello",
    body="World",
  )
  guard email.execute() is Ok(out) else { fail("expected ok") }
  assert_true(out.data.contains("user@test.com"))
  assert_true(out.data.contains("\"sent\": true"))
}

// ─── FilterComponent ───

///|
test "filter component: passthrough" {
  let f = @components.FilterComponent::new(condition="x > 0")
  let input = @components.ComponentInput::{ data: "test data", params: {} }
  guard f.execute(input) is Ok(out) else { fail("expected ok") }
  inspect(out.data, content="test data")
}

// ─── TransformComponent ───

///|
test "transform component: passthrough" {
  let t = @components.TransformComponent::new(template="{{data}}")
  let input = @components.ComponentInput::{ data: "raw input", params: {} }
  guard t.execute(input) is Ok(out) else { fail("expected ok") }
  inspect(out.data, content="raw input")
}

// ─── CacheComponent ───

///|
test "cache component: set and get" {
  let cache = @components.CacheComponent::new(ttl=60)
  inspect(cache.get("key"), content="None")
  cache.set("key", "value")
  inspect(cache.get("key"), content="Some(\"value\")")
}

///|
test "cache component: overwrite" {
  let cache = @components.CacheComponent::new()
  cache.set("k", "v1")
  cache.set("k", "v2")
  inspect(cache.get("k"), content="Some(\"v2\")")
}

// ─── CircuitBreakerComponent ───

///|
test "circuit breaker: starts closed and allows" {
  let cb = @components.CircuitBreakerComponent::new(failure_threshold=3)
  inspect(cb.is_allowed(), content="true")
  inspect(cb.state, content="Closed")
}

///|
test "circuit breaker: opens after threshold" {
  let cb = @components.CircuitBreakerComponent::new(failure_threshold=3)
  cb.record_failure()
  cb.record_failure()
  inspect(cb.is_allowed(), content="true")
  cb.record_failure()
  inspect(cb.state, content="Open")
  inspect(cb.is_allowed(), content="false")
}

///|
test "circuit breaker: resets on success" {
  let cb = @components.CircuitBreakerComponent::new(failure_threshold=2)
  cb.record_failure()
  cb.record_failure()
  inspect(cb.state, content="Open")
  cb.record_success()
  inspect(cb.state, content="Closed")
  inspect(cb.is_allowed(), content="true")
}

// ─── RateLimiterComponent ───

///|
test "rate limiter: allows within limit" {
  let rl = @components.RateLimiterComponent::new(max_requests=3)
  inspect(rl.allow(), content="true")
  inspect(rl.allow(), content="true")
  inspect(rl.allow(), content="true")
  inspect(rl.allow(), content="false")
}

///|
test "rate limiter: default limit" {
  let rl = @components.RateLimiterComponent::new()
  // Default is 100
  for _ in 0..<100 {
    assert_true(rl.allow())
  }
  inspect(rl.allow(), content="false")
}

// ─── RouterComponent ───

///|
test "router: add and check routes" {
  let router = @components.RouterComponent::new()
  router.add_route("/api/*", "api_handler")
  router.add_route("/web/*", "web_handler")
  inspect(router.routes.length(), content="2")
  inspect(router.routes["/api/*"], content="api_handler")
}

// ─── RetryComponent ───

///|
test "retry component: info" {
  let info = @components.RetryComponent::info()
  inspect(info.name, content="retry")
}

///|
test "retry component: creation" {
  let r = @components.RetryComponent::new(
    max_attempts=5,
    delay_ms=2000,
    backoff_multiplier=1.5,
  )
  inspect(r.max_attempts, content="5")
  inspect(r.delay_ms, content="2000")
}

// ─── format_component_error ───

///|
test "format_component_error" {
  inspect(
    @components.format_component_error(NetworkError("timeout")),
    content="Network error: timeout",
  )
  inspect(
    @components.format_component_error(AuthenticationError("invalid token")),
    content="Auth error: invalid token",
  )
  inspect(
    @components.format_component_error(TimeoutError),
    content="Timeout error",
  )
  inspect(
    @components.format_component_error(RateLimitError),
    content="Rate limit exceeded",
  )
}
