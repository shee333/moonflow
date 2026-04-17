///|
/// Black-box tests for runtime: context, executor, and workflow execution.

// ─── ExecutionContext tests ───

///|
test "context: create and set values" {
  let ctx = @runtime.ExecutionContext::new("test_wf")
  inspect(ctx.metadata.workflow_name, content="test_wf")
  ctx.set_value("key1", ValString("hello"))
  ctx.set_value("key2", ValNumber(42.0))
  ctx.set_value("key3", ValBool(true))
  ctx.set_value("key4", ValNull)
  inspect(ctx.get_value("key1"), content="Some(ValString(\"hello\"))")
  inspect(ctx.get_value("key2"), content="Some(ValNumber(42))")
  inspect(ctx.get_value("key3"), content="Some(ValBool(true))")
  inspect(ctx.get_value("key4"), content="Some(ValNull)")
  inspect(ctx.get_value("missing"), content="None")
}

///|
test "context: overwrite value" {
  let ctx = @runtime.ExecutionContext::new("wf")
  ctx.set_value("x", ValString("old"))
  ctx.set_value("x", ValString("new"))
  inspect(ctx.get_value("x"), content="Some(ValString(\"new\"))")
}

///|
test "context: node results" {
  let ctx = @runtime.ExecutionContext::new("wf")
  let result = @runtime.NodeResult::{
    node_id: "n1",
    status: Success,
    output: {},
    error_msg: None,
    duration_ms: 100,
  }
  ctx.set_node_result("n1", result)
  guard ctx.get_node_result("n1") is Some(r) else { fail("expected result") }
  inspect(r.node_id, content="n1")
  inspect(r.status, content="Success")
  inspect(r.duration_ms, content="100")
  assert_true(ctx.get_node_result("missing") is None)
}

///|
test "context: logging" {
  let ctx = @runtime.ExecutionContext::new("wf")
  ctx.add_log(Info, "Starting", Some("n1"))
  ctx.add_log(Error, "Failed", None)
  inspect(ctx.metadata.logs.length(), content="2")
  inspect(ctx.metadata.logs[0].message, content="Starting")
  inspect(ctx.metadata.logs[0].level, content="Info")
  inspect(ctx.metadata.logs[1].node_id, content="None")
}

// ─── Value utilities ───

///|
test "value_to_string" {
  inspect(@runtime.value_to_string(ValString("abc")), content="abc")
  inspect(@runtime.value_to_string(ValNumber(3.14)), content="3.14")
  inspect(@runtime.value_to_string(ValBool(false)), content="false")
  inspect(@runtime.value_to_string(ValNull), content="null")
}

///|
test "format_log_level" {
  inspect(@runtime.format_log_level(Debug), content="DEBUG")
  inspect(@runtime.format_log_level(Info), content="INFO")
  inspect(@runtime.format_log_level(Warning), content="WARN")
  inspect(@runtime.format_log_level(Error), content="ERROR")
}

///|
test "format_node_status" {
  inspect(@runtime.format_node_status(Pending), content="pending")
  inspect(@runtime.format_node_status(Running), content="running")
  inspect(@runtime.format_node_status(Success), content="success")
  inspect(@runtime.format_node_status(Failure), content="failure")
  inspect(@runtime.format_node_status(Skipped), content="skipped")
}

// ─── Node executor tests ───

///|
test "execute trigger node" {
  let node = @workflow.create_node(
    id="trig1",
    node_type=Trigger,
    label=Some("webhook"),
  )
  let ctx = @runtime.ExecutionContext::new("test")
  let result = @runtime.execute_node(node, ctx)
  inspect(result.status, content="Success")
  inspect(result.node_id, content="trig1")
  inspect(result.output["triggered"], content="ValBool(true)")
  inspect(result.output["trigger_type"], content="ValString(\"webhook\")")
}

///|
test "execute tool node: http" {
  let mut node = @workflow.create_node(id="http1", node_type=Tool)
  node = @workflow.Node::{
    ..node,
    config: { "tool": "http_get", "url": "http://api.test" },
  }
  let ctx = @runtime.ExecutionContext::new("test")
  let result = @runtime.execute_node(node, ctx)
  inspect(result.status, content="Success")
  inspect(result.output["url"], content="ValString(\"http://api.test\")")
  inspect(result.output["status_code"], content="ValNumber(200)")
}

///|
test "execute tool node: email" {
  let mut node = @workflow.create_node(id="em1", node_type=Tool)
  node = @workflow.Node::{
    ..node,
    config: { "tool": "email", "to": "a@b.com" },
  }
  let ctx = @runtime.ExecutionContext::new("test")
  let result = @runtime.execute_node(node, ctx)
  inspect(result.status, content="Success")
  inspect(result.output["sent"], content="ValBool(true)")
  inspect(result.output["to"], content="ValString(\"a@b.com\")")
}

///|
test "execute tool node: feishu" {
  let mut node = @workflow.create_node(id="fs1", node_type=Tool)
  node = @workflow.Node::{
    ..node,
    config: { "tool": "feishu", "webhook": "https://hook.test" },
  }
  let ctx = @runtime.ExecutionContext::new("test")
  let result = @runtime.execute_node(node, ctx)
  inspect(result.status, content="Success")
  inspect(result.output["sent"], content="ValBool(true)")
}

///|
test "execute tool node: generic" {
  let mut node = @workflow.create_node(id="gen1", node_type=Tool)
  node = @workflow.Node::{ ..node, config: { "tool": "custom_tool" } }
  let ctx = @runtime.ExecutionContext::new("test")
  let result = @runtime.execute_node(node, ctx)
  inspect(result.status, content="Success")
  inspect(result.output["tool"], content="ValString(\"custom_tool\")")
}

///|
test "execute agent node" {
  let mut node = @workflow.create_node(id="ag1", node_type=Agent)
  node = @workflow.Node::{
    ..node,
    config: { "model": "claude-3", "prompt": "Hello" },
  }
  let ctx = @runtime.ExecutionContext::new("test")
  let result = @runtime.execute_node(node, ctx)
  inspect(result.status, content="Success")
  inspect(result.output["model"], content="ValString(\"claude-3\")")
  inspect(result.output["tokens_used"], content="ValNumber(50)")
}

///|
test "execute control node: condition" {
  let node = @workflow.create_node(
    id="ctrl1",
    node_type=Control,
    label=Some("condition"),
  )
  let ctx = @runtime.ExecutionContext::new("test")
  let result = @runtime.execute_node(node, ctx)
  inspect(result.status, content="Success")
  inspect(result.output["branch"], content="ValString(\"true\")")
}

///|
test "execute control node: end" {
  let node = @workflow.create_node(
    id="end1",
    node_type=Control,
    label=Some("end"),
  )
  let ctx = @runtime.ExecutionContext::new("test")
  let result = @runtime.execute_node(node, ctx)
  inspect(result.status, content="Success")
  inspect(result.output["control"], content="ValString(\"end\")")
}

// ─── Workflow executor tests ───

///|
test "execute simple workflow successfully" {
  let wf = @workflow.create_workflow(
    name="simple",
    nodes=[
      @workflow.create_node(id="start", node_type=Trigger, label=Some("manual")),
      @workflow.create_node(id="process", node_type=Tool),
      @workflow.create_node(id="done", node_type=Control, label=Some("end")),
    ],
    edges=[
      @workflow.create_edge(from="start", to="process"),
      @workflow.create_edge(from="process", to="done"),
    ],
  )
  let result = @runtime.execute_workflow(wf)
  guard result is Ok(exec) else { fail("expected successful execution") }
  inspect(exec.status, content="WfCompleted")
  inspect(exec.error, content="None")
  inspect(exec.node_results.length(), content="3")
  // All nodes should succeed
  for _id, nr in exec.node_results {
    inspect(nr.status, content="Success")
  }
}

///|
test "execute workflow: validation failure" {
  let wf = @workflow.create_workflow(
    name="",
    nodes=[@workflow.create_node(id="a", node_type=Trigger)],
    edges=[],
  )
  let result = @runtime.execute_workflow(wf)
  guard result is Err(msg) else { fail("expected error") }
  assert_true(msg.contains("Validation failed"))
}

///|
test "format_workflow_status" {
  inspect(@runtime.format_workflow_status(WfPending), content="pending")
  inspect(@runtime.format_workflow_status(WfRunning), content="running")
  inspect(@runtime.format_workflow_status(WfCompleted), content="completed")
  inspect(@runtime.format_workflow_status(WfFailed), content="failed")
  inspect(@runtime.format_workflow_status(WfCancelled), content="cancelled")
}

///|
test "serialize_execution_to_json" {
  let wf = @workflow.create_workflow(
    name="ser_test",
    nodes=[
      @workflow.create_node(id="s1", node_type=Trigger),
      @workflow.create_node(id="s2", node_type=Tool),
    ],
    edges=[@workflow.create_edge(from="s1", to="s2")],
  )
  let result = @runtime.execute_workflow(wf)
  guard result is Ok(exec) else { fail("expected success") }
  let json_str = @runtime.serialize_execution_to_json(exec)
  assert_true(json_str.contains("\"success\":true"))
  assert_true(json_str.contains("\"status\":\"completed\""))
  assert_true(json_str.contains("ser_test"))
}
