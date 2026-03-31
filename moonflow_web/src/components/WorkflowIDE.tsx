import { useState, useCallback } from 'react';
import { DAGEditor } from './DAGEditor';
import { CodeEditor } from './CodeEditor';
import { ExecutionPanel } from './ExecutionPanel';
import './WorkflowIDE.css';

type ViewMode = 'dag' | 'code' | 'split';

export function WorkflowIDE() {
  const [viewMode, setViewMode] = useState<ViewMode>('split');
  const [showExecutionPanel, setShowExecutionPanel] = useState(true);
  const [isRunning, setIsRunning] = useState(false);
  const [workflowCode, setWorkflowCode] = useState<string>(JSON.stringify({
    id: 'workflow-1',
    name: 'Example Workflow',
    nodes: [
      { id: '1', type: 'http', label: 'HTTP Trigger', position: { x: 250, y: 5 } },
      { id: '2', type: 'llm', label: 'LLM Processor', position: { x: 100, y: 200 } },
      { id: '3', type: 'http', label: 'HTTP Request', position: { x: 400, y: 200 } },
      { id: '4', type: 'response', label: 'Response', position: { x: 250, y: 400 } },
    ],
    edges: [
      { source: '1', target: '2' },
      { source: '1', target: '3' },
      { source: '2', target: '4' },
      { source: '3', target: '4' },
    ],
  }, null, 2));

  const handleExport = useCallback(() => {
    const blob = new Blob([workflowCode], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'workflow.json';
    a.click();
    URL.revokeObjectURL(url);
  }, [workflowCode]);

  const handleImport = useCallback(() => {
    const input = document.createElement('input');
    input.type = 'file';
    input.accept = '.json';
    input.onchange = (e) => {
      const file = (e.target as HTMLInputElement).files?.[0];
      if (file) {
        const reader = new FileReader();
        reader.onload = (event) => {
          const content = event.target?.result as string;
          setWorkflowCode(content);
        };
        reader.readAsText(file);
      }
    };
    input.click();
  }, []);

  const handleRun = useCallback(() => {
    setIsRunning(true);
    setTimeout(() => setIsRunning(false), 10000);
  }, []);

  const handlePause = useCallback(() => {
    setIsRunning(false);
  }, []);

  const handleStop = useCallback(() => {
    setIsRunning(false);
  }, []);

  const handleReset = useCallback(() => {
    setIsRunning(false);
  }, []);

  return (
    <div className="workflow-ide">
      <div className="ide-header">
        <div className="header-left">
          <h1>🌙 MoonFlow Studio</h1>
        </div>
        <div className="header-center">
          <button
            className={viewMode === 'dag' ? 'active' : ''}
            onClick={() => setViewMode('dag')}
          >
            📊 DAG View
          </button>
          <button
            className={viewMode === 'code' ? 'active' : ''}
            onClick={() => setViewMode('code')}
          >
            💻 Code View
          </button>
          <button
            className={viewMode === 'split' ? 'active' : ''}
            onClick={() => setViewMode('split')}
          >
            ⬛ Split View
          </button>
          <button
            className={showExecutionPanel ? 'active' : ''}
            onClick={() => setShowExecutionPanel(!showExecutionPanel)}
          >
            🔧 {showExecutionPanel ? 'Hide' : 'Show'} Panel
          </button>
        </div>
        <div className="header-right">
          <button onClick={handleImport}>📂 Import</button>
          <button onClick={handleExport}>💾 Export</button>
          <button 
            className="primary" 
            onClick={handleRun}
            disabled={isRunning}
          >
            ▶️ {isRunning ? 'Running...' : 'Run'}
          </button>
        </div>
      </div>

      <div className={`ide-content ${viewMode}`}>
        {(viewMode === 'dag' || viewMode === 'split') && (
          <div className="dag-panel">
            <DAGEditor />
          </div>
        )}
        {(viewMode === 'code' || viewMode === 'split') && (
          <div className="code-panel">
            <div className="panel-header">
              <span>workflow.json</span>
            </div>
            <CodeEditor
              value={workflowCode}
              onChange={setWorkflowCode}
              language="json"
              height="100%"
            />
          </div>
        )}
        {showExecutionPanel && (
          <ExecutionPanel
            isRunning={isRunning}
            onStart={handleRun}
            onPause={handlePause}
            onStop={handleStop}
            onReset={handleReset}
          />
        )}
      </div>

      <div className="ide-footer">
        <div className="status">
          <span className="status-indicator"></span>
          {isRunning ? 'Running' : 'Ready'}
        </div>
        <div className="info">
          MoonFlow Studio v0.1.0 | Node.js 20.18.0
        </div>
      </div>
    </div>
  );
}
