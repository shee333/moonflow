///|
/// Component registry - manages available components.

///|
pub(all) struct ComponentRegistry {
  components : Map[String, ComponentInfo]
}

///|
pub fn ComponentRegistry::new() -> ComponentRegistry {
  let reg = ComponentRegistry::{ components: {} }
  reg.register(HttpComponent::info())
  reg.register(LlmComponent::info())
  reg.register(EmailComponent::info())
  reg.register(FeishuComponent::info())
  reg.register(FilterComponent::info())
  reg.register(TransformComponent::info())
  reg.register(CacheComponent::info())
  reg.register(RetryComponent::info())
  reg.register(RateLimiterComponent::info())
  reg.register(CircuitBreakerComponent::info())
  reg.register(RouterComponent::info())
  reg
}

///|
pub fn ComponentRegistry::register(
  self : ComponentRegistry,
  info : ComponentInfo,
) -> Unit {
  self.components[info.name] = info
}

///|
pub fn ComponentRegistry::get(
  self : ComponentRegistry,
  name : String,
) -> ComponentInfo? {
  self.components.get(name)
}

///|
pub fn ComponentRegistry::list(
  self : ComponentRegistry,
) -> Array[ComponentInfo] {
  let result : Array[ComponentInfo] = []
  for _k, v in self.components {
    result.push(v)
  }
  result
}

///|
pub fn ComponentRegistry::count(self : ComponentRegistry) -> Int {
  self.components.length()
}
