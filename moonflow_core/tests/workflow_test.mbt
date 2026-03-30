package moonflow_core::tests

fn test_duplicate_node_id_detection() {
  let nodes = [
    moonflow_core::workflow::Node::{
      id: "node1",
      node_type: moonflow_core::workflow::NodeType::Trigger,
      label: None,
      with: {},
      timeout: None,
      retry: None,
      condition: None,
      isolation: None,
      approval: None,
    },
    moonflow_core::workflow::Node::{
      id: "node1",
      node_type: moonflow_core::workflow::NodeType::Tool,
      label: None,
      with: {},
      timeout: None,
      retry: None,
      condition: None,
      isolation: None,
      approval: None,
    },
  ]

  let workflow = moonflow_core::workflow::Workflow::{
    version: "v1",
    name: "test_workflow",
    description: None,
    metadata: None,
    nodes,
    edges: [],
    config: None,
  }

  let result = moonflow_core::workflow::validate_workflow(workflow)
  match result {
    Err(moonflow_core::workflow::ValidationError::DuplicateNodeId(id)) => {
      assert id == "node1"
    }
    _ => {
      println("Expected duplicate node ID error")
      assert false
    }
  }
}

fn test_valid_workflow() {
  let nodes = [
    moonflow_core::workflow::Node::{
      id: "trigger",
      node_type: moonflow_core::workflow::NodeType::Trigger,
      label: Some("Timer Trigger"),
      with: {"schedule": "0 9 * * *"},
      timeout: None,
      retry: None,
      condition: None,
      isolation: None,
      approval: None,
    },
    moonflow_core::workflow::Node::{
      id: "fetch",
      node_type: moonflow_core::workflow::NodeType::Tool,
      label: Some("HTTP Fetch"),
      with: {"url": "https://api.example.com"},
      timeout: Some(10000),
      retry: Some(moonflow_core::workflow::RetryConfig::{
        max_attempts: 3,
        strategy: moonflow_core::workflow::RetryStrategy::ExponentialBackoff,
        initial_delay: Some(1000),
      }),
      condition: None,
      isolation: None,
      approval: None,
    },
  ]

  let edges = [
    moonflow_core::workflow::Edge::{
      from: "trigger",
      to: "fetch",
      label: None,
      condition: None,
      data_mapping: None,
    },
  ]

  let workflow = moonflow_core::workflow::Workflow::{
    version: "v1",
    name: "test_workflow",
    description: Some("A valid test workflow"),
    metadata: Some(moonflow_core::workflow::NodeMetadata::{
      author: Some("Test Author"),
      version: Some("1.0.0"),
      tags: Some(["test"]),
    }),
    nodes,
    edges,
    config: Some(moonflow_core::workflow::WorkflowConfig::{
      timeout: Some(60000),
      retry: None,
      concurrency: Some(5),
    }),
  }

  let result = moonflow_core::workflow::validate_workflow(workflow)
  match result {
    Ok(_) => {
      println("Valid workflow passed validation")
      assert true
    }
    Err(e) => {
      let error_msg = moonflow_core::workflow::format_validation_error(e)
      println("Unexpected validation error: \{error_msg}")
      assert false
    }
  }
}

fn test_invalid_edge_reference() {
  let nodes = [
    moonflow_core::workflow::Node::{
      id: "node1",
      node_type: moonflow_core::workflow::NodeType::Trigger,
      label: None,
      with: {},
      timeout: None,
      retry: None,
      condition: None,
      isolation: None,
      approval: None,
    },
  ]

  let edges = [
    moonflow_core::workflow::Edge::{
      from: "node1",
      to: "nonexistent",
      label: None,
      condition: None,
      data_mapping: None,
    },
  ]

  let workflow = moonflow_core::workflow::Workflow::{
    version: "v1",
    name: "test_workflow",
    description: None,
    metadata: None,
    nodes,
    edges,
    config: None,
  }

  let result = moonflow_core::workflow::validate_workflow(workflow)
  match result {
    Err(moonflow_core::workflow::ValidationError::InvalidEdgeReference(id)) => {
      assert id == "nonexistent"
    }
    _ => {
      println("Expected invalid edge reference error")
      assert false
    }
  }
}

fn test_missing_required_fields() {
  let workflow = moonflow_core::workflow::Workflow::{
    version: "",
    name: "test_workflow",
    description: None,
    metadata: None,
    nodes: [],
    edges: [],
    config: None,
  }

  let result = moonflow_core::workflow::validate_workflow(workflow)
  match result {
    Err(moonflow_core::workflow::ValidationError::MissingRequiredField(entity, field)) => {
      assert entity == "workflow"
      assert field == "nodes" || field == "version"
    }
    _ => {
      println("Expected missing required field error")
      assert false
    }
  }
}

#[test]
fn run_workflow_tests() {
  println("Running workflow validation tests...")
  test_duplicate_node_id_detection()
  test_valid_workflow()
  test_invalid_edge_reference()
  test_missing_required_fields()
  println("All workflow tests passed!")
}
