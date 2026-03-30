package moonflow_core::runtime

pub type ExecutionState =
  | Pending
  | Running
  | Completed
  | Failed
  | Cancelled

pub struct NodeExecution {
  node_id: String
  state: ExecutionState
  result: NodeResult?
  start_time: Int?
  end_time: Int?
  error: String?
  retry_count: Int
}

pub type NodeResult = String

pub struct ExecutionContext {
  workflow_id: String
  execution_id: String
  node_results: Map[String, NodeResult]
  variables: Map[String, String]
  start_time: Int
  end_time: Int?
  node_executions: Map[String, NodeExecution]
  max_concurrency: Int
}

pub struct DAGNode {
  id: String
  dependencies: Array[String]
  dependents: Array[String]
  in_degree: Int
  out_degree: Int
}

pub struct DAG {
  nodes: Map[String, DAGNode]
  adjacency_list: Map[String, Array[String]]
  reverse_adjacency_list: Map[String, Array[String]]
}

pub fn create_dag(nodes: Array[moonflow_core::workflow::Node], edges: Array[moonflow_core::workflow::Edge]) -> DAG {
  let dag = DAG::{
    nodes: {},
    adjacency_list: {},
    reverse_adjacency_list: {},
  }

  for node in nodes {
    dag.nodes[node.id] = DAGNode::{
      id: node.id,
      dependencies: [],
      dependents: [],
      in_degree: 0,
      out_degree: 0,
    }
    dag.adjacency_list[node.id] = []
    dag.reverse_adjacency_list[node.id] = []
  }

  for edge in edges {
    match dag.adjacency_list[edge.from] {
      Some(arr) => arr.push(edge.to)
      None => dag.adjacency_list[edge.from] = [edge.to]
    }
    match dag.reverse_adjacency_list[edge.to] {
      Some(arr) => arr.push(edge.from)
      None => dag.reverse_adjacency_list[edge.to] = [edge.from]
    }

    match dag.nodes[edge.from] {
      Some(dag_node) => {
        dag_node.dependents.push(edge.to)
        dag_node.out_degree = dag_node.out_degree + 1
      }
      None => ()
    }

    match dag.nodes[edge.to] {
      Some(dag_node) => {
        dag_node.dependencies.push(edge.from)
        dag_node.in_degree = dag_node.in_degree + 1
      }
      None => ()
    }
  }

  dag
}

pub fn topological_sort(dag: DAG) -> Array[String] {
  let result: Array[String] = []
  let in_degree: Map[String, Int] = {}
  let queue: Array[String] = []

  for (node_id, node) in dag.nodes {
    in_degree[node_id] = node.in_degree
    if node.in_degree == 0 {
      queue.push(node_id)
    }
  }

  while queue.length() > 0 {
    let current = queue.shift().unwrap()
    result.push(current)

    match dag.adjacency_list[current] {
      Some(neighbors) => {
        for neighbor in neighbors {
          match in_degree[neighbor] {
            Some(degree) => {
              let new_degree = degree - 1
              in_degree[neighbor] = new_degree
              if new_degree == 0 {
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

  result
}

pub fn get_ready_nodes(dag: DAG, completed_nodes: Map[String, Bool], running_nodes: Map[String, Bool]) -> Array[String] {
  let ready: Array[String] = []

  for (node_id, node) in dag.nodes {
    match completed_nodes[node_id] {
      Some(true) => ()
      None => {
        match running_nodes[node_id] {
          Some(true) => ()
          None => {
            let all_deps_complete = true
            for dep in node.dependencies {
              match completed_nodes[dep] {
                Some(true) => ()
                None => {
                  all_deps_complete = false
                }
              }
            }
            if all_deps_complete {
              ready.push(node_id)
            }
          }
        }
      }
    }
  }

  ready
}

pub fn create_execution_context(
  workflow_id: String,
  nodes: Array[moonflow_core::workflow::Node],
  config: moonflow_core::workflow::WorkflowConfig?
) -> ExecutionContext {
  let node_executions: Map[String, NodeExecution] = {}
  for node in nodes {
    node_executions[node.id] = NodeExecution::{
      node_id: node.id,
      state: ExecutionState::Pending,
      result: None,
      start_time: None,
      end_time: None,
      error: None,
      retry_count: 0,
    }
  }

  let max_concurrency = match config {
    Some(c) => c.concurrency.unwrap_or(1)
    None => 1
  }

  ExecutionContext::{
    workflow_id,
    execution_id: generate_execution_id(),
    node_results: {},
    variables: {},
    start_time: get_current_timestamp(),
    end_time: None,
    node_executions,
    max_concurrency,
  }
}

pub fn generate_execution_id() -> String {
  let timestamp = get_current_timestamp().to_string()
  let random = generate_random_string(8)
  "exec_\{timestamp}_\{random}"
}

pub fn get_current_timestamp() -> Int {
  0
}

pub fn generate_random_string(length: Int) -> String {
  let chars = "abcdefghijklmnopqrstuvwxyz0123456789"
  let result = ""
  let i = 0
  while i < length {
    let idx = 0
    result = result + chars.substring(idx, idx + 1)
    i = i + 1
  }
  result
}

pub fn mark_node_running(ctx: ExecutionContext, node_id: String) -> ExecutionContext {
  match ctx.node_executions[node_id] {
    Some(exec) => {
      exec.state = ExecutionState::Running
      exec.start_time = Some(get_current_timestamp())
    }
    None => ()
  }
  ctx
}

pub fn mark_node_completed(ctx: ExecutionContext, node_id: String, result: NodeResult) -> ExecutionContext {
  match ctx.node_executions[node_id] {
    Some(exec) => {
      exec.state = ExecutionState::Completed
      exec.result = Some(result)
      exec.end_time = Some(get_current_timestamp())
    }
    None => ()
  }
  ctx.node_results[node_id] = result
  ctx
}

pub fn mark_node_failed(ctx: ExecutionContext, node_id: String, error: String) -> ExecutionContext {
  match ctx.node_executions[node_id] {
    Some(exec) => {
      exec.state = ExecutionState::Failed
      exec.error = Some(error)
      exec.end_time = Some(get_current_timestamp())
    }
    None => ()
  }
  ctx
}

pub fn check_all_completed(ctx: ExecutionContext) -> Bool {
  for (_, exec) in ctx.node_executions {
    match exec.state {
      ExecutionState::Completed => ()
      _ => return false
    }
  }
  true
}

pub fn check_any_failed(ctx: ExecutionContext) -> Bool {
  for (_, exec) in ctx.node_executions {
    match exec.state {
      ExecutionState::Failed => return true
      _ => ()
    }
  }
  false
}
