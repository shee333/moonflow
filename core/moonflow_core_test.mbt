package moonflow_core_test

import @moonflow_core::workflow::{Workflow, Node, Edge, NodeType, validate_workflow, ValidationError}
import @moonflow_core

fn create_simple_workflow() -> Workflow {
  {
    version: "1.0.0",
    name: "Test Workflow",
    description: Some("A simple test workflow"),
    nodes: [
      {
        id: "start",
        node_type: NodeType::Trigger,
        label: Some("Start"),
        with: {},
        condition: None,
      },
      {
        id: "process",
        node_type: NodeType::Tool,
        label: Some("Process"),
        with: {"action": "test"},
        condition: None,
      },
    ],
    edges: [
      { from: "start", to: "process", label: None, condition: None, data_mapping: None },
    ],
    config: None,
  }
}

test "validate_workflow: valid workflow passes" {
  let workflow = create_simple_workflow()
  let result = validate_workflow(workflow)
  inspect!(result, content="Ok(Unit)")
}

test "validate_workflow: duplicate node ids fail" {
  let workflow = {
    version: "1.0.0",
    name: "Duplicate Nodes",
    nodes: [
      { id: "node1", node_type: NodeType::Trigger, label: Some("Node 1"), with: {}, condition: None },
      { id: "node1", node_type: NodeType::Tool, label: Some("Node 2"), with: {}, condition: None },
    ],
    edges: [],
    config: None,
  }
  let result = validate_workflow(workflow)
  match result {
    Err(ValidationError::DuplicateNodeId(id)) => inspect!(id, content="\"node1\"")
    Ok(_) => inspect!(result, content="Err(DuplicateNodeId(\"node1\"))")
  }
}

test "validate_workflow: invalid edge reference fails" {
  let workflow = {
    version: "1.0.0",
    name: "Invalid Edge",
    nodes: [
      { id: "start", node_type: NodeType::Trigger, label: Some("Start"), with: {}, condition: None },
    ],
    edges: [
      { from: "start", to: "nonexistent", label: None, condition: None, data_mapping: None },
    ],
    config: None,
  }
  let result = validate_workflow(workflow)
  match result {
    Err(ValidationError::InvalidEdgeReference(id)) => inspect!(id, content="\"nonexistent\"")
    Ok(_) => inspect!(result, content="Err(InvalidEdgeReference(\"nonexistent\"))")
  }
}

test "validate_workflow: empty workflow passes structural validation" {
  let workflow = {
    version: "1.0.0",
    name: "Empty Workflow",
    nodes: [],
    edges: [],
    config: None,
  }
  let result = validate_workflow(workflow)
  inspect!(result, content="Ok(Unit)")
}
