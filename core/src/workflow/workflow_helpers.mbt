package moonflow_core::workflow

pub fn create_node(
  id: String,
  node_type: NodeType,
  label: String,
  description: String,
  config: Map[String, String]
) -> Node {
  Node::{
    id,
    node_type,
    label: Some(label),
    description: if description == "" { None } else { Some(description) },
    config,
  }
}

pub fn create_edge(
  id: String,
  source: String,
  target: String,
  label: String
) -> Edge {
  Edge::{
    id,
    source,
    target,
    label: if label == "" { None } else { Some(label) },
  }
}

pub fn create_workflow(
  name: String,
  version: String,
  nodes: Array[Node],
  edges: Array[Edge]
) -> Workflow {
  Workflow::{
    name,
    version,
    nodes,
    edges,
    metadata: {},
  }
}

pub fn get_node_by_id(workflow: Workflow, node_id: String) -> Node? {
  for node in workflow.nodes {
    if node.id == node_id {
      return Some(node)
    }
  }
  None
}

pub fn get_nodes_by_type(workflow: Workflow, node_type: NodeType) -> Array[Node] {
  let result: Array[Node] = []
  for node in workflow.nodes {
    if node.node_type == node_type {
      result.push(node)
    }
  }
  result
}

pub fn get_trigger_nodes(workflow: Workflow) -> Array[Node] {
  get_nodes_by_type(workflow, NodeType::Trigger)
}

pub fn get_tool_nodes(workflow: Workflow) -> Array[Node] {
  get_nodes_by_type(workflow, NodeType::Tool)
}

pub fn get_agent_nodes(workflow: Workflow) -> Array[Node] {
  get_nodes_by_type(workflow, NodeType::Agent)
}

pub fn get_control_nodes(workflow: Workflow) -> Array[Node] {
  get_nodes_by_type(workflow, NodeType::Control)
}

pub fn get_outgoing_edges(workflow: Workflow, node_id: String) -> Array[Edge] {
  let result: Array[Edge] = []
  for edge in workflow.edges {
    if edge.source == node_id {
      result.push(edge)
    }
  }
  result
}

pub fn get_incoming_edges(workflow: Workflow, node_id: String) -> Array[Edge] {
  let result: Array[Edge] = []
  for edge in workflow.edges {
    if edge.target == node_id {
      result.push(edge)
    }
  }
  result
}

pub fn count_nodes_by_type(workflow: Workflow) -> Map[NodeType, Int] {
  let counts: Map[NodeType, Int] = {}
  counts[NodeType::Trigger] = 0
  counts[NodeType::Tool] = 0
  counts[NodeType::Agent] = 0
  counts[NodeType::Control] = 0
  
  for node in workflow.nodes {
    match counts[node.node_type] {
      Some(count) => counts[node.node_type] = count + 1
      None => counts[node.node_type] = 1
    }
  }
  counts
}

pub fn has_cycle(workflow: Workflow) -> Bool {
  let visited: Map[String, Bool] = {}
  let rec_stack: Map[String, Bool] = {}
  
  for node in workflow.nodes {
    visited[node.id] = false
    rec_stack[node.id] = false
  }
  
  for node in workflow.nodes {
    if detect_cycle_from(node.id, workflow, visited, rec_stack) {
      return true
    }
  }
  false
}

fn detect_cycle_from(
  node_id: String,
  workflow: Workflow,
  visited: Map[String, Bool],
  rec_stack: Map[String, Bool]
) -> Bool {
  match visited[node_id] {
    Some(true) => return false
    _ => visited[node_id] = true
  }
  
  rec_stack[node_id] = true
  
  let outgoing = get_outgoing_edges(workflow, node_id)
  for edge in outgoing {
    let target = edge.target
    match rec_stack[target] {
      Some(true) => return true
      _ => ()
    }
    if detect_cycle_from(target, workflow, visited, rec_stack) {
      return true
    }
  }
  
  rec_stack[node_id] = false
  false
}

pub fn get_execution_order(workflow: Workflow) -> Result[Array[String], String] {
  if has_cycle(workflow) {
    return Err("Workflow contains a cycle")
  }
  
  let in_degree: Map[String, Int] = {}
  let adjacency: Map[String, Array[String]] = {}
  
  for node in workflow.nodes {
    in_degree[node.id] = 0
    adjacency[node.id] = []
  }
  
  for edge in workflow.edges {
    let targets = adjacency[edge.source]
    match targets {
      Some(list) => adjacency[edge.source] = list + [edge.target]
      None => adjacency[edge.source] = [edge.target]
    }
    match in_degree[edge.target] {
      Some(deg) => in_degree[edge.target] = deg + 1
      None => in_degree[edge.target] = 1
    }
  }
  
  let queue: Array[String] = []
  let result: Array[String] = []
  
  for (node_id, degree) in in_degree {
    if degree == 0 {
      queue.push(node_id)
    }
  }
  
  while queue.length() > 0 {
    let node_id = queue[0]
    queue.remove(0)
    result.push(node_id)
    
    match adjacency[node_id] {
      Some(neighbors) => {
        for neighbor in neighbors {
          match in_degree[neighbor] {
            Some(deg) => {
              in_degree[neighbor] = deg - 1
              if deg - 1 == 0 {
                queue.push(neighbor)
              }
            }
            None => ()
          }
        }
      }
      None => ()
    }
  }
  
  if result.length() != workflow.nodes.length() {
    return Err("Cannot determine execution order")
  }
  
  Ok(result)
}

pub fn validate_workflow_completeness(workflow: Workflow) -> Array[ValidationIssue] {
  let issues: Array[ValidationIssue] = []
  
  let trigger_nodes = get_trigger_nodes(workflow)
  if trigger_nodes.length() == 0 {
    issues.push(ValidationIssue::{
      severity: Severity::Error,
      message: "Workflow has no trigger nodes",
      node_id: None,
    })
  }
  
  let control_nodes = get_control_nodes(workflow)
  let end_nodes = control_nodes.filter(fn(n: Node) -> Bool {
    match n.config["end_type"] {
      Some(t) => t == "end"
      None => false
    }
  })
  if end_nodes.length() == 0 {
    issues.push(ValidationIssue::{
      severity: Severity::Warning,
      message: "Workflow has no explicit end node",
      node_id: None,
    })
  }
  
  for node in workflow.nodes {
    if node.label.is_none() {
      issues.push(ValidationIssue::{
        severity: Severity::Warning,
        message: "Node has no label",
        node_id: Some(node.id),
      })
    }
    
    let outgoing = get_outgoing_edges(workflow, node.id)
    if outgoing.length() == 0 && node.node_type != NodeType::Control {
      issues.push(ValidationIssue::{
        severity: Severity::Warning,
        message: "Node has no outgoing edges",
        node_id: Some(node.id),
      })
    }
  }
  
  issues
}

pub struct ValidationIssue {
  severity: Severity
  message: String
  node_id: Option[String]
}

pub enum Severity {
  | Warning
  | Error
  | Info
}
