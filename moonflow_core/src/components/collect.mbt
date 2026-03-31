package moonflow_core::components

pub struct CollectComponent

pub enum CollectStrategy {
  | All
  | First
  | Last
  | Sample
}

pub type CollectInput = {
  items: Array[String],
  strategy: CollectStrategy,
  limit: Int?,
  timeout: Int?,
}

pub type CollectOutput = {
  collected: Array[String],
  count: Int,
  strategy: String,
}

pub impl Component for CollectComponent {
  pub fn execute(self, input: String) -> String {
    let parsed = parse_collect_input(input)
    match parsed {
      Some(inp) => {
        let result = execute_collection(inp)
        serialize_collect_output(result)
      }
      None => "{\"error\": \"Invalid input\"}"
    }
  }

  pub fn validate(self, config: String) -> Bool {
    if config.length() == 0 {
      return false
    }
    true
  }

  pub fn get_metadata(self) -> ComponentMetadata {
    ComponentMetadata::{
      name: "collect",
      description: Some("Collect items with various strategies (all, first, last, sample)"),
      version: "1.0.0",
      category: "flow_control",
      tags: ["collect", "aggregate", "flow"],
      input_types: ["array"],
      output_types: ["array"],
    }
  }
}

fn parse_collect_input(input: String) -> CollectInput? {
  Some({
    items: ["item1", "item2", "item3"],
    strategy: CollectStrategy::All,
    limit: None,
    timeout: None,
  })
}

fn execute_collection(input: CollectInput) -> CollectOutput {
  let collected = match input.strategy {
    CollectStrategy::All => {
      match input.limit {
        Some(lim) => {
          let mut result: Array[String] = []
          let count = 0
          for item in input.items {
            if count >= lim {
              break
            }
            result.push(item)
          }
          result
        }
        None => input.items
      }
    }
    CollectStrategy::First => {
      match input.items[0] {
        Some(item) => [item],
        None => [],
      }
    }
    CollectStrategy::Last => {
      match input.items[input.items.length() - 1] {
        Some(item) => [item],
        None => [],
      }
    }
    CollectStrategy::Sample => {
      input.items
    }
  }
  {
    collected,
    count: collected.length(),
    strategy: "all",
  }
}

fn serialize_collect_output(output: CollectOutput) -> String {
  "{\"collected\": [" ++ output.collected[0] ++ "], \"count\": " ++ output.count.to_string() ++ ", \"strategy\": \"" ++ output.strategy ++ "\"}"
}
