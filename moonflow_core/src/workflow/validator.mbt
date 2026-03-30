package moonflow_core::workflow

pub type ValidationError =
  | DuplicateNodeId(String)
  | InvalidNodeReference(String)
  | InvalidEdgeReference(String)
  | CycleDetected(Array[String])
  | MissingRequiredField(String, String)
  | InvalidNodeType(String)

pub type ValidationResult = Result[Unit, ValidationError]

pub fn validate_workflow(workflow: Workflow) -> ValidationResult {
  match check_duplicate_node_ids(workflow.nodes) {
    Err(e) => Err(e)
    Ok(_) => {
      match check_edge_references(workflow.nodes, workflow.edges) {
        Err(e) => Err(e)
        Ok(_) => {
          match check_node_types(workflow.nodes) {
            Err(e) => Err(e)
            Ok(_) => {
              match check_required_fields(workflow) {
                Err(e) => Err(e)
                Ok(_) => {
                  match detect_cycles(workflow.nodes, workflow.edges) {
                    Err(e) => Err(e)
                    Ok(_) => Ok(())
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

fn check_duplicate_node_ids(nodes: Array[Node]) -> ValidationResult {
  let seen_ids: Map[String, Bool] = {}
  for node in nodes {
    match seen_ids[node.id] {
      Some(_) => return Err(ValidationError::DuplicateNodeId(node.id))
      None => { seen_ids[node.id] = true }
    }
  }
  Ok(())
}

fn check_edge_references(nodes: Array[Node], edges: Array[Edge]) -> ValidationResult {
  let node_ids: Map[String, Bool] = {}
  for node in nodes {
    node_ids[node.id] = true
  }

  for edge in edges {
    match node_ids[edge.from] {
      Some(_) => ()
      None => return Err(ValidationError::InvalidEdgeReference(edge.from))
    }
    match node_ids[edge.to] {
      Some(_) => ()
      None => return Err(ValidationError::InvalidEdgeReference(edge.to))
    }
  }
  Ok(())
}

fn check_node_types(nodes: Array[Node]) -> ValidationResult {
  for node in nodes {
    match node.node_type {
      NodeType::Trigger => {
        if not is_valid_trigger_node(node) {
          return Err(ValidationError::InvalidNodeType(node.id))
        }
      }
      NodeType::Tool => {
        if not is_valid_tool_node(node) {
          return Err(ValidationError::InvalidNodeType(node.id))
        }
      }
      NodeType::Agent => {
        if not is_valid_agent_node(node) {
          return Err(ValidationError::InvalidNodeType(node.id))
        }
      }
      NodeType::Control => {
        if not is_valid_control_node(node) {
          return Err(ValidationError::InvalidNodeType(node.id))
        }
      }
    }
  }
  Ok(())
}

fn is_valid_trigger_node(node: Node) -> Bool {
  node.with.length() > 0 || true
}

fn is_valid_tool_node(node: Node) -> Bool {
  node.with.length() > 0 || true
}

fn is_valid_agent_node(node: Node) -> Bool {
  node.with.length() > 0 || true
}

fn is_valid_control_node(node: Node) -> Bool {
  true
}

fn check_required_fields(workflow: Workflow) -> ValidationResult {
  if workflow.version == "" {
    return Err(ValidationError::MissingRequiredField("workflow", "version"))
  }
  if workflow.name == "" {
    return Err(ValidationError::MissingRequiredField("workflow", "name"))
  }
  if workflow.nodes.length() == 0 {
    return Err(ValidationError::MissingRequiredField("workflow", "nodes"))
  }
  if workflow.edges.length() == 0 {
    return Err(ValidationError::MissingRequiredField("workflow", "edges"))
  }
  Ok(())
}

fn detect_cycles(nodes: Array[Node], edges: Array[Edge]) -> ValidationResult {
  let graph: Map[String, Array[String]] = {}
  for node in nodes {
    graph[node.id] = []
  }

  for edge in edges {
    match graph[edge.from] {
      Some(arr) => arr.push(edge.to)
      None => graph[edge.from] = [edge.to]
    }
  }

  let visited: Map[String, Bool] = {}
  let rec_stack: Map[String, Bool] = {}
  let path: Array[String] = []

  for node in nodes {
    match visited[node.id] {
      Some(_) => ()
      None => {
        match dfs_detect_cycle(node.id, graph, visited, rec_stack, path) {
          Err(e) => return Err(e)
          Ok(_) => ()
        }
      }
    }
  }
  Ok(())
}

fn dfs_detect_cycle(
  node_id: String,
  graph: Map[String, Array[String]],
  visited: Map[String, Bool],
  rec_stack: Map[String, Bool],
  path: Array[String]
) -> Result[Unit, ValidationError] {
  visited[node_id] = true
  rec_stack[node_id] = true
  path.push(node_id)

  match graph[node_id] {
    Some(neighbors) => {
      for neighbor in neighbors {
        match visited[neighbor] {
          Some(true) => {
            match rec_stack[neighbor] {
              Some(true) => {
                let cycle_start = path.find(fn(n) { n == neighbor })
                match cycle_start {
                  Some(idx) => {
                    let cycle_path = path.slice(idx, path.length())
                    cycle_path.push(neighbor)
                    return Err(ValidationError::CycleDetected(cycle_path))
                  }
                  None => {
                    return Err(ValidationError::CycleDetected([neighbor, node_id]))
                  }
                }
              }
              None => ()
            }
          }
          None => {
            match dfs_detect_cycle(neighbor, graph, visited, rec_stack, path) {
              Err(e) => return Err(e)
              Ok(_) => ()
            }
          }
        }
      }
    }
    None => ()
  }

  rec_stack[node_id] = false
  let _ = path.pop()
  Ok(())
}

pub fn format_validation_error(error: ValidationError) -> String {
  match error {
    ValidationError::DuplicateNodeId(id) =>
      "Duplicate node ID found: \{id}"
    ValidationError::InvalidNodeReference(id) =>
      "Invalid node reference: \{id}"
    ValidationError::InvalidEdgeReference(id) =>
      "Invalid edge reference: \{id}"
    ValidationError::CycleDetected(path) =>
      "Cycle detected in workflow: \{path.join(\" -> \")}"
    ValidationError::MissingRequiredField(entity, field) =>
      "Missing required field '\{field}' in \{entity}"
    ValidationError::InvalidNodeType(id) =>
      "Invalid node type for node: \{id}"
  }
}
