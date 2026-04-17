///|
/// Workflow validation: duplicate IDs, edge refs, cycle detection, required fields.

///|
pub enum ValidationError {
  DuplicateNodeId(String)
  InvalidNodeReference(String)
  InvalidEdgeReference(String)
  CycleDetected(Array[String])
  MissingRequiredField(String, String)
  InvalidNodeType(String)
} derive(Show)

///|
pub fn validate_workflow(workflow : Workflow) -> Result[Unit, ValidationError] {
  let r1 = check_duplicate_node_ids(workflow.nodes)
  guard r1 is Ok(_) else { return r1 }
  let r2 = check_edge_references(workflow.nodes, workflow.edges)
  guard r2 is Ok(_) else { return r2 }
  let r3 = check_node_types(workflow.nodes)
  guard r3 is Ok(_) else { return r3 }
  let r4 = check_required_fields(workflow)
  guard r4 is Ok(_) else { return r4 }
  detect_cycles(workflow.nodes, workflow.edges)
}

///|
fn check_duplicate_node_ids(
  nodes : Array[Node],
) -> Result[Unit, ValidationError] {
  let seen : Map[String, Bool] = {}
  for node in nodes {
    if seen.contains(node.id) {
      return Err(DuplicateNodeId(node.id))
    }
    seen[node.id] = true
  }
  Ok(())
}

///|
fn check_edge_references(
  nodes : Array[Node],
  edges : Array[Edge],
) -> Result[Unit, ValidationError] {
  let ids : Map[String, Bool] = {}
  for node in nodes {
    ids[node.id] = true
  }
  for edge in edges {
    if !ids.contains(edge.from) {
      return Err(InvalidEdgeReference(edge.from))
    }
    if !ids.contains(edge.to) {
      return Err(InvalidEdgeReference(edge.to))
    }
  }
  Ok(())
}

///|
fn check_node_types(nodes : Array[Node]) -> Result[Unit, ValidationError] {
  for node in nodes {
    if node.id == "" {
      return Err(InvalidNodeType(node.id))
    }
  }
  Ok(())
}

///|
fn check_required_fields(workflow : Workflow) -> Result[Unit, ValidationError] {
  if workflow.version == "" {
    return Err(MissingRequiredField("workflow", "version"))
  }
  if workflow.name == "" {
    return Err(MissingRequiredField("workflow", "name"))
  }
  if workflow.nodes.length() == 0 {
    return Err(MissingRequiredField("workflow", "nodes"))
  }
  Ok(())
}

///|
fn detect_cycles(
  nodes : Array[Node],
  edges : Array[Edge],
) -> Result[Unit, ValidationError] {
  let graph : Map[String, Array[String]] = {}
  for node in nodes {
    graph[node.id] = []
  }
  for edge in edges {
    match graph.get(edge.from) {
      Some(arr) => arr.push(edge.to)
      None => graph[edge.from] = [edge.to]
    }
  }
  let visited : Map[String, Bool] = {}
  let in_stack : Map[String, Bool] = {}
  for node in nodes {
    if !visited.contains(node.id) {
      match dfs_cycle(node.id, graph, visited, in_stack) {
        Err(e) => return Err(e)
        Ok(_) => ()
      }
    }
  }
  Ok(())
}

///|
fn dfs_cycle(
  node_id : String,
  graph : Map[String, Array[String]],
  visited : Map[String, Bool],
  in_stack : Map[String, Bool],
) -> Result[Unit, ValidationError] {
  visited[node_id] = true
  in_stack[node_id] = true
  match graph.get(node_id) {
    Some(neighbors) =>
      for neighbor in neighbors {
        if in_stack.contains(neighbor) {
          return Err(CycleDetected([node_id, neighbor]))
        }
        if !visited.contains(neighbor) {
          match dfs_cycle(neighbor, graph, visited, in_stack) {
            Err(e) => return Err(e)
            Ok(_) => ()
          }
        }
      }
    None => ()
  }
  in_stack.remove(node_id) |> ignore
  Ok(())
}

///|
pub fn format_validation_error(error : ValidationError) -> String {
  match error {
    DuplicateNodeId(id) => "Duplicate node ID: " + id
    InvalidNodeReference(id) => "Invalid node reference: " + id
    InvalidEdgeReference(id) => "Invalid edge reference: " + id
    CycleDetected(path) => {
      let sep = " -> "
      "Cycle detected: " + path.join(sep)
    }
    MissingRequiredField(entity, field) =>
      "Missing required field " + field + " in " + entity
    InvalidNodeType(id) => "Invalid node type for node: " + id
  }
}
