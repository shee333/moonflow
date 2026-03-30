import json
import threading
import time
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path


class WorkflowEngine:
    def __init__(self, workflow, max_workers=4):
        self.workflow = workflow
        self.max_workers = max_workers
        self.nodes = {n["id"]: n for n in workflow["nodes"]}
        self.results = {}
        self.state = {n["id"]: "pending" for n in workflow["nodes"]}
        self.remaining_deps = {
            n["id"]: len(n.get("depends_on", [])) for n in workflow["nodes"]
        }
        self.dependents = {n["id"]: [] for n in workflow["nodes"]}
        self.lock = threading.Lock()
        self.done_event = threading.Event()
        self.total_nodes = len(workflow["nodes"])
        self.completed_nodes = 0
        self.validate()
        self.build_reverse_edges()

    def validate(self):
        for node in self.workflow["nodes"]:
            for dep in node.get("depends_on", []):
                if dep not in self.nodes:
                    raise ValueError(f"节点 {node['id']} 依赖了不存在的节点 {dep}")
        indegree = {
            n["id"]: len(n.get("depends_on", [])) for n in self.workflow["nodes"]
        }
        queue = [nid for nid, deg in indegree.items() if deg == 0]
        visited = 0
        local_deps = {n["id"]: [] for n in self.workflow["nodes"]}
        for node in self.workflow["nodes"]:
            for dep in node.get("depends_on", []):
                local_deps[dep].append(node["id"])
        while queue:
            current = queue.pop(0)
            visited += 1
            for nxt in local_deps[current]:
                indegree[nxt] -= 1
                if indegree[nxt] == 0:
                    queue.append(nxt)
        if visited != len(self.workflow["nodes"]):
            raise ValueError("工作流存在环，无法执行")

    def build_reverse_edges(self):
        for node in self.workflow["nodes"]:
            for dep in node.get("depends_on", []):
                self.dependents[dep].append(node["id"])

    def run_node_logic(self, node, dep_outputs, attempt):
        node_type = node["type"]
        config = node.get("config", {})
        if node_type == "sleep_value":
            delay = float(config.get("delay_sec", 1))
            value = config.get("value")
            time.sleep(delay)
            return value
        if node_type == "sum":
            return sum(dep_outputs)
        if node_type == "multiply":
            factor = config.get("factor", 1)
            base = dep_outputs[0] if dep_outputs else 0
            return base * factor
        if node_type == "flaky_increment":
            fail_times = int(config.get("fail_times", 0))
            inc = config.get("increment", 1)
            base = dep_outputs[0] if dep_outputs else 0
            if attempt <= fail_times:
                raise RuntimeError(f"模拟失败，第 {attempt} 次执行失败")
            return base + inc
        if node_type == "format":
            template = config.get("template", "{value}")
            value = dep_outputs[0] if dep_outputs else None
            return template.format(value=value)
        if node_type == "print":
            value = dep_outputs[0] if dep_outputs else None
            print(f"[PRINT] {value}")
            return value
        raise ValueError(f"未知节点类型: {node_type}")

    def execute_node(self, node_id):
        node = self.nodes[node_id]
        retry = node.get("retry", {})
        max_retries = int(retry.get("max_retries", 0))
        retry_delay = float(retry.get("delay_sec", 0))
        deps = node.get("depends_on", [])
        dep_outputs = [self.results[d] for d in deps]
        total_attempts = max_retries + 1
        for attempt in range(1, total_attempts + 1):
            try:
                start = time.time()
                output = self.run_node_logic(node, dep_outputs, attempt)
                elapsed = (time.time() - start) * 1000
                with self.lock:
                    self.results[node_id] = output
                    self.state[node_id] = "success"
                print(f"[OK] {node_id} attempt={attempt} elapsed={elapsed:.1f}ms output={output}")
                return
            except Exception as e:
                is_last = attempt == total_attempts
                if is_last:
                    with self.lock:
                        self.state[node_id] = "failed"
                    print(f"[FAILED] {node_id} attempt={attempt} error={e}")
                    self.done_event.set()
                    return
                print(f"[RETRY] {node_id} attempt={attempt} error={e}")
                if retry_delay > 0:
                    time.sleep(retry_delay)

    def submit_ready_nodes(self, executor):
        with self.lock:
            ready = [
                nid
                for nid, cnt in self.remaining_deps.items()
                if cnt == 0 and self.state[nid] == "pending"
            ]
            for nid in ready:
                self.state[nid] = "running"
                executor.submit(self.node_done_wrapper, nid, executor)

    def node_done_wrapper(self, node_id, executor):
        self.execute_node(node_id)
        with self.lock:
            if self.state[node_id] == "success":
                self.completed_nodes += 1
                for nxt in self.dependents[node_id]:
                    self.remaining_deps[nxt] -= 1
            elif self.state[node_id] == "failed":
                return
            if self.completed_nodes == self.total_nodes:
                self.done_event.set()
        self.submit_ready_nodes(executor)

    def run(self):
        start = time.time()
        with ThreadPoolExecutor(max_workers=self.max_workers) as executor:
            self.submit_ready_nodes(executor)
            while not self.done_event.wait(0.1):
                with self.lock:
                    if any(v == "failed" for v in self.state.values()):
                        break
            with self.lock:
                final_failed = [k for k, v in self.state.items() if v == "failed"]
                all_done = self.completed_nodes == self.total_nodes
        elapsed = time.time() - start
        print(f"\n总耗时: {elapsed:.2f}s")
        if final_failed:
            print(f"执行失败节点: {final_failed}")
            return False
        if all_done:
            print("工作流执行成功")
            print(f"最终输出: {self.results}")
            return True
        print("工作流未完成")
        return False


def main():
    workflow_path = Path(__file__).parent / "workflow.json"
    workflow = json.loads(workflow_path.read_text(encoding="utf-8"))
    engine = WorkflowEngine(workflow, max_workers=4)
    success = engine.run()
    if not success:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
