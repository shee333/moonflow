///|
/// Workflow helper functions: constructors, queries, serialization.

///|
pub enum Severity {
  SevWarning
  SevError
  SevInfo
}

///|
pub struct WorkflowIssue {
  severity : Severity
  message : String
  node_id : String?
}

///|
pub fn create_node(
  id~ : String,
  node_type~ : NodeType,
  label? : String? = None,
) -> Node {
  Node::{
    id,
    node_type,
    label,
    config: {},
    timeout: None,
    retry: None,
    condition: None,
    isolation: None,
    approval: None,
  }
}

///|
pub fn create_edge(
  from~ : String,
  to~ : String,
  label? : String? = None,
  condition? : String? = None,
) -> Edge {
  Edge::{ from, to, label, condition, data_mapping: None }
}

///|
pub fn create_workflow(
  name~ : String,
  nodes~ : Array[Node],
  edges~ : Array[Edge],
  version? : String = "1.0",
  description? : String? = None,
) -> Workflow {
  Workflow::{
    version,
    name,
    description,
    metadata: None,
    nodes,
    edges,
    config: None,
  }
}

///|
pub fn get_execution_order(workflow : Workflow) -> Array[String] {
  let in_degree : Map[String, Int] = {}
  let graph : Map[String, Array[String]] = {}
  for node in workflow.nodes {
    in_degree[node.id] = 0
    graph[node.id] = []
  }
  for edge in workflow.edges {
    match graph.get(edge.from) {
      Some(arr) => arr.push(edge.to)
      None => graph[edge.from] = [edge.to]
    }
    let deg = in_degree.get(edge.to).unwrap_or(0)
    in_degree[edge.to] = deg + 1
  }
  let queue : Array[String] = []
  for id, deg in in_degree {
    if deg == 0 {
      queue.push(id)
    }
  }
  let order : Array[String] = []
  while queue.length() > 0 {
    let current = queue.unsafe_pop()
    order.push(current)
    match graph.get(current) {
      Some(neighbors) =>
        for neighbor in neighbors {
          let d = in_degree.get(neighbor).unwrap_or(0)
          in_degree[neighbor] = d - 1
          if d - 1 == 0 {
            queue.push(neighbor)
          }
        }
      None => ()
    }
  }
  order
}

///|
pub fn has_cycle(workflow : Workflow) -> Bool {
  match validate_workflow(workflow) {
    Ok(_) => false
    Err(CycleDetected(_)) => true
    Err(_) => false
  }
}

///|
pub fn validate_workflow_completeness(
  workflow : Workflow,
) -> Array[WorkflowIssue] {
  let issues : Array[WorkflowIssue] = []
  for node in workflow.nodes {
    if node.label is None {
      issues.push(WorkflowIssue::{
        severity: SevWarning,
        message: "Node has no label: " + node.id,
        node_id: Some(node.id),
      })
    }
    match node.node_type {
      Trigger =>
        if node.config.length() == 0 {
          issues.push(WorkflowIssue::{
            severity: SevInfo,
            message: "Trigger has no configuration: " + node.id,
            node_id: Some(node.id),
          })
        }
      _ => ()
    }
  }
  if workflow.description is None {
    issues.push(WorkflowIssue::{
      severity: SevInfo,
      message: "Workflow has no description",
      node_id: None,
    })
  }
  issues
}

///|
pub fn serialize_workflow_to_json(workflow : Workflow) -> String {
  let buf = StringBuilder::new()
  buf.write_string("{")
  buf.write_string("\"version\": \"")
  buf.write_string(workflow.version)
  buf.write_string("\", \"name\": \"")
  buf.write_string(workflow.name)
  buf.write_string("\"")
  match workflow.description {
    Some(desc) => {
      buf.write_string(", \"description\": \"")
      buf.write_string(desc)
      buf.write_string("\"")
    }
    None => ()
  }
  buf.write_string(", \"nodes\": [")
  for i, node in workflow.nodes {
    if i > 0 {
      buf.write_string(", ")
    }
    let type_str = format_node_type(node.node_type)
    buf.write_string("{\"id\": \"")
    buf.write_string(node.id)
    buf.write_string("\", \"type\": \"")
    buf.write_string(type_str)
    buf.write_string("\"")
    match node.label {
      Some(lbl) => {
        buf.write_string(", \"label\": \"")
        buf.write_string(lbl)
        buf.write_string("\"")
      }
      None => ()
    }
    buf.write_string("}")
  }
  buf.write_string("]")
  buf.write_string(", \"edges\": [")
  for i, edge in workflow.edges {
    if i > 0 {
      buf.write_string(", ")
    }
    buf.write_string("{\"from\": \"")
    buf.write_string(edge.from)
    buf.write_string("\", \"to\": \"")
    buf.write_string(edge.to)
    buf.write_string("\"")
    match edge.label {
      Some(lbl) => {
        buf.write_string(", \"label\": \"")
        buf.write_string(lbl)
        buf.write_string("\"")
      }
      None => ()
    }
    buf.write_string("}")
  }
  buf.write_string("]")
  buf.write_string("}")
  buf.to_string()
}

///|
pub fn format_node_type(nt : NodeType) -> String {
  match nt {
    Trigger => "trigger"
    Tool => "tool"
    Agent => "agent"
    Control => "control"
  }
}
