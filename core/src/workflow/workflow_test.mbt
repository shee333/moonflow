///|
/// Black-box tests for workflow types, parser, validator, and helpers.

// ─── Parser: basic workflow parsing ───

///|
test "parse minimal workflow" {
  let json =
    #|{"name":"test","nodes":[{"id":"n1","type":"trigger"}],"edges":[]}
  let wf = @workflow.parse_workflow_json(json)
  inspect(wf.name, content="test")
  inspect(wf.version, content="v1")
  inspect(wf.nodes.length(), content="1")
  inspect(wf.edges.length(), content="0")
  inspect(wf.nodes[0].id, content="n1")
  inspect(wf.nodes[0].node_type, content="Trigger")
}

///|
test "parse workflow with description and metadata" {
  let json =
    #|{
    #|  "name":"my_flow",
    #|  "version":"2.0",
    #|  "description":"A test workflow",
    #|  "metadata":{"author":"dev","version":"0.1","tags":["ai","test"]},
    #|  "nodes":[{"id":"a","type":"tool","label":"HTTP Call","with":{"url":"http://example.com","timeout":"5000"}}],
    #|  "edges":[]
    #|}
  let wf = @workflow.parse_workflow_json(json)
  inspect(wf.name, content="my_flow")
  inspect(wf.version, content="2.0")
  inspect(wf.description, content="Some(\"A test workflow\")")
  guard wf.metadata is Some(m) else { fail("expected metadata") }
  inspect(m.author, content="Some(\"dev\")")
  inspect(m.version, content="Some(\"0.1\")")
  guard m.tags is Some(tags) else { fail("expected tags") }
  inspect(tags.length(), content="2")
  // Node config from "with" block
  let node = wf.nodes[0]
  inspect(node.label, content="Some(\"HTTP Call\")")
  inspect(node.config["url"], content="http://example.com")
  inspect(node.config["timeout"], content="5000")
}

///|
test "parse edges with from/to and source/target" {
  let json =
    #|{
    #|  "name":"edge_test",
    #|  "nodes":[{"id":"a","type":"trigger"},{"id":"b","type":"tool"}],
    #|  "edges":[
    #|    {"from":"a","to":"b","label":"step1"},
    #|    {"source":"b","target":"a","label":"back"}
    #|  ]
    #|}
  let wf = @workflow.parse_workflow_json(json)
  inspect(wf.edges.length(), content="2")
  inspect(wf.edges[0].from, content="a")
  inspect(wf.edges[0].to, content="b")
  inspect(wf.edges[0].label, content="Some(\"step1\")")
  inspect(wf.edges[1].from, content="b")
  inspect(wf.edges[1].to, content="a")
}

///|
test "parse node types" {
  let json =
    #|{
    #|  "name":"types","nodes":[
    #|    {"id":"t1","type":"trigger"},
    #|    {"id":"t2","type":"tool_http"},
    #|    {"id":"t3","type":"agent_llm"},
    #|    {"id":"t4","type":"control_end"},
    #|    {"id":"t5","type":"llm"},
    #|    {"id":"t6","type":"condition"},
    #|    {"id":"t7","type":"http"}
    #|  ],"edges":[]
    #|}
  let wf = @workflow.parse_workflow_json(json)
  inspect(wf.nodes[0].node_type, content="Trigger")
  inspect(wf.nodes[1].node_type, content="Tool")
  inspect(wf.nodes[2].node_type, content="Agent")
  inspect(wf.nodes[3].node_type, content="Control")
  inspect(wf.nodes[4].node_type, content="Agent")
  inspect(wf.nodes[5].node_type, content="Control")
  inspect(wf.nodes[6].node_type, content="Tool")
}

///|
test "parse retry config" {
  let json =
    #|{
    #|  "name":"retry_test",
    #|  "nodes":[{"id":"n1","type":"tool","retry":{"max_attempts":5,"strategy":"linear","initial_delay":2000}}],
    #|  "edges":[]
    #|}
  let wf = @workflow.parse_workflow_json(json)
  guard wf.nodes[0].retry is Some(r) else { fail("expected retry config") }
  inspect(r.max_attempts, content="5")
  inspect(r.strategy, content="Linear")
  inspect(r.initial_delay, content="2000")
}

///|
test "parse isolation and approval config" {
  let json =
    #|{
    #|  "name":"iso_test",
    #|  "nodes":[{
    #|    "id":"n1","type":"tool",
    #|    "isolation":{"mode":"sandbox","timeout":5000,"network":false},
    #|    "approval":{"required":true,"approvers":["admin"],"timeout":3600,"message":"Needs review"}
    #|  }],
    #|  "edges":[]
    #|}
  let wf = @workflow.parse_workflow_json(json)
  guard wf.nodes[0].isolation is Some(iso) else { fail("expected isolation") }
  inspect(iso.mode, content="sandbox")
  inspect(iso.timeout, content="Some(5000)")
  inspect(iso.network, content="Some(false)")
  guard wf.nodes[0].approval is Some(appr) else { fail("expected approval") }
  inspect(appr.required, content="true")
  inspect(appr.timeout, content="Some(3600)")
  inspect(appr.message, content="Some(\"Needs review\")")
}

///|
test "parse workflow config" {
  let json =
    #|{
    #|  "name":"cfg_test",
    #|  "nodes":[{"id":"n1","type":"trigger"}],
    #|  "edges":[],
    #|  "config":{"timeout":60000,"concurrency":4}
    #|}
  let wf = @workflow.parse_workflow_json(json)
  guard wf.config is Some(cfg) else { fail("expected config") }
  inspect(cfg.timeout, content="Some(60000)")
  inspect(cfg.concurrency, content="Some(4)")
}

// ─── Parser: error cases ───

///|
test "parse error: invalid JSON" {
  let result : Result[_, _] = try? @workflow.parse_workflow_json("not json")
  guard result is Err(_) else { fail("expected parse error") }
}

///|
test "parse error: missing name" {
  let result : Result[_, _] = try? @workflow.parse_workflow_json(
    "{\"nodes\":[],\"edges\":[]}",
  )
  guard result is Err(_) else { fail("expected missing name error") }
}

///|
test "parse error: missing nodes" {
  let result : Result[_, _] = try? @workflow.parse_workflow_json(
    "{\"name\":\"test\",\"edges\":[]}",
  )
  guard result is Err(_) else { fail("expected missing nodes error") }
}

///|
test "parse error: unknown node type" {
  let result : Result[_, _] = try? @workflow.parse_workflow_json(
    "{\"name\":\"test\",\"nodes\":[{\"id\":\"n1\",\"type\":\"xyz_unknown\"}],\"edges\":[]}",
  )
  guard result is Err(_) else { fail("expected unknown type error") }
}

///|
test "parse error: non-object root" {
  let result : Result[_, _] = try? @workflow.parse_workflow_json("[1,2,3]")
  guard result is Err(_) else { fail("expected object error") }
}

// ─── Validator tests ───

///|
test "validate valid workflow" {
  let wf = @workflow.create_workflow(
    name="valid",
    nodes=[
      @workflow.create_node(id="a", node_type=Trigger),
      @workflow.create_node(id="b", node_type=Tool),
    ],
    edges=[@workflow.create_edge(from="a", to="b")],
  )
  inspect(@workflow.validate_workflow(wf), content="Ok(())")
}

///|
test "validate duplicate node IDs" {
  let wf = @workflow.create_workflow(
    name="dup",
    nodes=[
      @workflow.create_node(id="x", node_type=Trigger),
      @workflow.create_node(id="x", node_type=Tool),
    ],
    edges=[],
  )
  let result = @workflow.validate_workflow(wf)
  guard result is Err(DuplicateNodeId("x")) else {
    fail("expected DuplicateNodeId")
  }
}

///|
test "validate invalid edge reference" {
  let wf = @workflow.create_workflow(
    name="bad_edge",
    nodes=[@workflow.create_node(id="a", node_type=Trigger)],
    edges=[@workflow.create_edge(from="a", to="missing")],
  )
  let result = @workflow.validate_workflow(wf)
  guard result is Err(InvalidEdgeReference("missing")) else {
    fail("expected InvalidEdgeReference")
  }
}

///|
test "validate missing required fields" {
  let wf = @workflow.create_workflow(
    name="",
    nodes=[@workflow.create_node(id="a", node_type=Trigger)],
    edges=[],
  )
  let result = @workflow.validate_workflow(wf)
  guard result is Err(MissingRequiredField(_, _)) else {
    fail("expected MissingRequiredField")
  }
}

///|
test "validate cycle detection" {
  let wf = @workflow.create_workflow(
    name="cycle",
    nodes=[
      @workflow.create_node(id="a", node_type=Trigger),
      @workflow.create_node(id="b", node_type=Tool),
    ],
    edges=[
      @workflow.create_edge(from="a", to="b"),
      @workflow.create_edge(from="b", to="a"),
    ],
  )
  let result = @workflow.validate_workflow(wf)
  guard result is Err(CycleDetected(_)) else { fail("expected CycleDetected") }
}

///|
test "format_validation_error" {
  let r1 = @workflow.validate_workflow(
    @workflow.create_workflow(
      name="dup",
      nodes=[
        @workflow.create_node(id="n1", node_type=Trigger),
        @workflow.create_node(id="n1", node_type=Tool),
      ],
      edges=[],
    ),
  )
  guard r1 is Err(e1) else { fail("expected error") }
  inspect(
    @workflow.format_validation_error(e1),
    content="Duplicate node ID: n1",
  )
  let r2 = @workflow.validate_workflow(
    @workflow.create_workflow(
      name="bad",
      nodes=[@workflow.create_node(id="a", node_type=Trigger)],
      edges=[@workflow.create_edge(from="a", to="missing")],
    ),
  )
  guard r2 is Err(e2) else { fail("expected error") }
  inspect(
    @workflow.format_validation_error(e2),
    content="Invalid edge reference: missing",
  )
  let r3 = @workflow.validate_workflow(
    @workflow.create_workflow(
      name="",
      nodes=[@workflow.create_node(id="a", node_type=Trigger)],
      edges=[],
    ),
  )
  guard r3 is Err(e3) else { fail("expected error") }
  inspect(
    @workflow.format_validation_error(e3),
    content="Missing required field name in workflow",
  )
}

// ─── Workflow helpers tests ───

///|
test "create_node default values" {
  let node = @workflow.create_node(id="test", node_type=Tool)
  inspect(node.id, content="test")
  inspect(node.node_type, content="Tool")
  inspect(node.label, content="None")
  inspect(node.config.length(), content="0")
  inspect(node.timeout, content="None")
  assert_true(node.retry is None)
}

///|
test "create_edge with label" {
  let edge = @workflow.create_edge(
    from="a",
    to="b",
    label=Some("next"),
    condition=Some("x > 0"),
  )
  inspect(edge.from, content="a")
  inspect(edge.to, content="b")
  inspect(edge.label, content="Some(\"next\")")
  inspect(edge.condition, content="Some(\"x > 0\")")
}

///|
test "get_execution_order linear chain" {
  let wf = @workflow.create_workflow(
    name="chain",
    nodes=[
      @workflow.create_node(id="a", node_type=Trigger),
      @workflow.create_node(id="b", node_type=Tool),
      @workflow.create_node(id="c", node_type=Control),
    ],
    edges=[
      @workflow.create_edge(from="a", to="b"),
      @workflow.create_edge(from="b", to="c"),
    ],
  )
  let order = @workflow.get_execution_order(wf)
  inspect(order.length(), content="3")
  inspect(order[0], content="a")
  inspect(order[1], content="b")
  inspect(order[2], content="c")
}

///|
test "get_execution_order diamond" {
  // a -> b, a -> c, b -> d, c -> d
  let wf = @workflow.create_workflow(
    name="diamond",
    nodes=[
      @workflow.create_node(id="a", node_type=Trigger),
      @workflow.create_node(id="b", node_type=Tool),
      @workflow.create_node(id="c", node_type=Tool),
      @workflow.create_node(id="d", node_type=Control),
    ],
    edges=[
      @workflow.create_edge(from="a", to="b"),
      @workflow.create_edge(from="a", to="c"),
      @workflow.create_edge(from="b", to="d"),
      @workflow.create_edge(from="c", to="d"),
    ],
  )
  let order = @workflow.get_execution_order(wf)
  inspect(order.length(), content="4")
  inspect(order[0], content="a")
  // b and c can be in either order, but d must be last
  inspect(order[3], content="d")
}

///|
test "has_cycle returns false for DAG" {
  let wf = @workflow.create_workflow(
    name="dag",
    nodes=[
      @workflow.create_node(id="a", node_type=Trigger),
      @workflow.create_node(id="b", node_type=Tool),
    ],
    edges=[@workflow.create_edge(from="a", to="b")],
  )
  inspect(@workflow.has_cycle(wf), content="false")
}

///|
test "has_cycle returns true for cycle" {
  let wf = @workflow.create_workflow(
    name="cyc",
    nodes=[
      @workflow.create_node(id="a", node_type=Trigger),
      @workflow.create_node(id="b", node_type=Tool),
      @workflow.create_node(id="c", node_type=Tool),
    ],
    edges=[
      @workflow.create_edge(from="a", to="b"),
      @workflow.create_edge(from="b", to="c"),
      @workflow.create_edge(from="c", to="a"),
    ],
  )
  inspect(@workflow.has_cycle(wf), content="true")
}

///|
test "validate_workflow_completeness warnings" {
  let wf = @workflow.create_workflow(
    name="incomplete",
    nodes=[
      @workflow.create_node(id="a", node_type=Trigger),
      @workflow.create_node(id="b", node_type=Tool),
    ],
    edges=[],
  )
  let issues = @workflow.validate_workflow_completeness(wf)
  // Nodes without labels + no description = at least 3 issues
  assert_true(issues.length() >= 3)
}

///|
test "format_node_type" {
  inspect(@workflow.format_node_type(Trigger), content="trigger")
  inspect(@workflow.format_node_type(Tool), content="tool")
  inspect(@workflow.format_node_type(Agent), content="agent")
  inspect(@workflow.format_node_type(Control), content="control")
}

///|
test "serialize_workflow_to_json roundtrip" {
  let wf = @workflow.create_workflow(
    name="serial",
    nodes=[
      @workflow.create_node(id="s1", node_type=Trigger, label=Some("Start")),
      @workflow.create_node(id="s2", node_type=Tool),
    ],
    edges=[@workflow.create_edge(from="s1", to="s2", label=Some("go"))],
    description=Some("test desc"),
  )
  let json_str = @workflow.serialize_workflow_to_json(wf)
  // Parse back
  let parsed = @workflow.parse_workflow_json(json_str)
  inspect(parsed.name, content="serial")
  inspect(parsed.description, content="Some(\"test desc\")")
  inspect(parsed.nodes.length(), content="2")
  inspect(parsed.edges.length(), content="1")
}
