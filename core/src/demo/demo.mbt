///|
/// MoonFlow Demo
fn main {
  println("===========================================")
  println("  MoonFlow Demo")
  println("===========================================")
  println("")

  println("[1] Creating workflow...")
  let nodes : Array[@workflow.Node] = [
    @workflow.create_node(
      id="start",
      node_type=@workflow.Trigger,
      label=Some("Manual Trigger"),
    ),
    @workflow.create_node(
      id="fetch",
      node_type=@workflow.Tool,
      label=Some("HTTP Fetch"),
    ),
    @workflow.create_node(
      id="process",
      node_type=@workflow.Agent,
      label=Some("LLM Process"),
    ),
    @workflow.create_node(
      id="done",
      node_type=@workflow.Control,
      label=Some("End"),
    ),
  ]
  let edges : Array[@workflow.Edge] = [
    @workflow.create_edge(from="start", to="fetch"),
    @workflow.create_edge(from="fetch", to="process"),
    @workflow.create_edge(from="process", to="done"),
  ]
  let wf = @workflow.create_workflow(name="demo_workflow", nodes~, edges~)
  println("  Name: " + wf.name)
  println("  Nodes: " + wf.nodes.length().to_string())
  println("  Edges: " + wf.edges.length().to_string())
  println("")

  println("[2] Validating...")
  match @workflow.validate_workflow(wf) {
    Ok(_) => println("  Validation passed")
    Err(e) =>
      println("  Validation failed: " + @workflow.format_validation_error(e))
  }
  println("")

  println("[3] Executing...")
  match @runtime.execute_workflow(wf) {
    Ok(result) => {
      println("  Status: " + @runtime.format_workflow_status(result.status))
      println("  Nodes executed: " + result.node_results.length().to_string())
    }
    Err(e) => println("  Failed: " + e)
  }
  println("")

  println("[4] Parsing from JSON...")
  let json_str = "{\"version\":\"1.0\",\"name\":\"json_test\",\"nodes\":[{\"id\":\"a\",\"type\":\"trigger\",\"label\":\"Start\"},{\"id\":\"b\",\"type\":\"tool\",\"label\":\"Process\"},{\"id\":\"c\",\"type\":\"control\",\"label\":\"End\"}],\"edges\":[{\"from\":\"a\",\"to\":\"b\"},{\"from\":\"b\",\"to\":\"c\"}]}"
  let parsed = @workflow.parse_workflow_json(json_str) catch {
    e => {
      println("  Parse error: " + e.to_string())
      return
    }
  }
  println(
    "  Parsed: " +
    parsed.name +
    " (" +
    parsed.nodes.length().to_string() +
    " nodes)",
  )

  println("")
  println("[5] Serializing...")
  let output = @workflow.serialize_workflow_to_json(wf)
  println("  " + output)

  println("")
  println("===========================================")
  println("  Demo completed!")
  println("===========================================")
}
