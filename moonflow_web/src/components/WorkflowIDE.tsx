import { useState, useCallback } from 'react';
import { DAGEditor } from './DAGEditor';
import { CodeEditor } from './CodeEditor';
import { ExecutionPanel } from './ExecutionPanel';
import { CodePreview } from './CodePreview';
import { WorkflowManager } from './WorkflowManager';
import { KeyboardShortcutsHelp } from './KeyboardShortcutsHelp';
import { AnalyticsDashboard } from './AnalyticsDashboard';
import { generateMoonBitCode, validateWorkflow } from '../utils/codeGenerator';
import { Workflow } from './types';
import { useTheme } from '../context';
import './WorkflowIDE.css';

type ViewMode = 'dag' | 'code' | 'split';

export function WorkflowIDE() {
  const [viewMode, setViewMode] = useState<ViewMode>('split');
  const [showExecutionPanel, setShowExecutionPanel] = useState(true);
  const [isRunning, setIsRunning] = useState(false);
  const [validationResult, setValidationResult] = useState<{ valid: boolean; errors: string[] } | null>(null);
  const { theme, toggleTheme } = useTheme();
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
          setValidationResult(null);
        };
        reader.readAsText(file);
      }
    };
    input.click();
  }, []);

  const handleLoadWorkflow = useCallback((workflowId: string) => {
    const stored = localStorage.getItem('moonflow_workflows');
    if (stored) {
      try {
        const workflows = JSON.parse(stored);
        const workflow = workflows.find((w: any) => w.id === workflowId);
        if (workflow) {
          const workflowData = {
            id: workflow.id,
            name: workflow.name,
            nodes: [],
            edges: [],
          };
          setWorkflowCode(JSON.stringify(workflowData, null, 2));
          setValidationResult(null);
        }
      } catch (e) {
        console.error('Failed to load workflow:', e);
      }
    }
  }, []);

  const handleSaveWorkflow = useCallback((name: string, description: string) => {
    alert(`工作流 "${name}" 已保存！`);
  }, []);

  const handleValidate = useCallback(() => {
    try {
      const workflow: Workflow = JSON.parse(workflowCode);
      const result = validateWorkflow(workflow);
      setValidationResult(result);
    } catch (error) {
      setValidationResult({
        valid: false,
        errors: ['Invalid JSON format: ' + (error as Error).message],
      });
    }
  }, [workflowCode]);

  const handleGenerateCode = useCallback(() => {
    try {
      const workflow: Workflow = JSON.parse(workflowCode);
      const result = validateWorkflow(workflow);
      setValidationResult(result);
      
      if (result.valid) {
        const moonBitCode = generateMoonBitCode(workflow);
        const blob = new Blob([moonBitCode], { type: 'text/plain' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `${workflow.name || 'workflow'}.mbt`;
        a.click();
        URL.revokeObjectURL(url);
      }
    } catch (error) {
      setValidationResult({
        valid: false,
        errors: ['Invalid JSON format: ' + (error as Error).message],
      });
    }
  }, [workflowCode]);

  const handleRun = useCallback(() => {
    try {
      const workflow: Workflow = JSON.parse(workflowCode);
      const result = validateWorkflow(workflow);
      setValidationResult(result);
      
      if (result.valid) {
        setIsRunning(true);
        setTimeout(() => setIsRunning(false), 10000);
      }
    } catch (error) {
      setValidationResult({
        valid: false,
        errors: ['Invalid JSON format: ' + (error as Error).message],
      });
    }
  }, [workflowCode]);

  const handlePause = useCallback(() => {
    setIsRunning(false);
  }, []);

  const handleStop = useCallback(() => {
    setIsRunning(false);
  }, []);

  const handleReset = useCallback(() => {
    setIsRunning(false);
    setValidationResult(null);
  }, []);

  return (
    <div className="workflow-ide" data-theme={theme}>
      <CodePreview />
      {validationResult && (
        <div
          style={{
            position: 'fixed',
            top: '60px',
            left: '50%',
            transform: 'translateX(-50%)',
            zIndex: 1001,
            padding: validationResult.valid ? '12px 24px' : '12px 24px',
            backgroundColor: validationResult.valid ? '#28a745' : '#dc3545',
            color: 'white',
            borderRadius: validationResult.valid ? '8px' : '8px 8px 0 0',
            boxShadow: '0 4px 12px rgba(0,0,0,0.3)',
            maxWidth: '600px',
            textAlign: 'center',
          }}
        >
          {validationResult.valid ? (
            <div>
              <strong>✓ 工作流验证通过！</strong>
              <div style={{ fontSize: '12px', marginTop: '4px' }}>
                工作流已准备好执行
              </div>
            </div>
          ) : (
            <div>
              <strong>✗ 验证失败</strong>
              <ul style={{ textAlign: 'left', marginTop: '8px', fontSize: '12px', maxHeight: '150px', overflowY: 'auto' }}>
                {validationResult.errors.map((error, i) => (
                  <li key={i}>{error}</li>
                ))}
              </ul>
            </div>
          )}
          <button
            onClick={() => setValidationResult(null)}
            style={{
              marginTop: '8px',
              padding: '4px 12px',
              backgroundColor: 'rgba(255,255,255,0.2)',
              border: 'none',
              borderRadius: '4px',
              color: 'white',
              cursor: 'pointer',
              fontSize: '12px',
            }}
          >
            关闭
          </button>
        </div>
      )}

      <div className="ide-header">
        <div className="header-left">
          <h1>🌙 MoonFlow 工作流设计器</h1>
        </div>
        <div className="header-center">
          <button
            className={viewMode === 'dag' ? 'active' : ''}
            onClick={() => setViewMode('dag')}
          >
            图谱视图
          </button>
          <button
            className={viewMode === 'code' ? 'active' : ''}
            onClick={() => setViewMode('code')}
          >
            代码视图
          </button>
          <button
            className={viewMode === 'split' ? 'active' : ''}
            onClick={() => setViewMode('split')}
          >
            分屏视图
          </button>
        </div>
        <div className="header-right">
          <button onClick={handleImport} className="secondary">
            📥 导入
          </button>
          <button onClick={handleExport} className="secondary">
            📤 导出
          </button>
          <button onClick={handleValidate} className="secondary">
            ✓ 验证
          </button>
          <button onClick={handleGenerateCode} className="secondary">
            ⚡ 生成代码
          </button>
          {!isRunning ? (
            <button onClick={handleRun} className="primary">
              ▶️ 运行
            </button>
          ) : (
            <button onClick={handleStop} className="danger">
              ⏹️ 停止
            </button>
          )}
          <button
            onClick={() => setShowExecutionPanel(!showExecutionPanel)}
            className={showExecutionPanel ? 'active' : ''}
          >
            📋 {showExecutionPanel ? '隐藏' : '显示'} 日志
          </button>
          <button
            onClick={toggleTheme}
            className="secondary"
            title={`切换到 ${theme === 'dark' ? '浅色' : '深色'} 主题`}
          >
            {theme === 'dark' ? '☀️ 浅色' : '🌙 深色'}
          </button>
        </div>
      </div>

      <div className="ide-content">
        <div
          className="editor-area"
          style={{
            flexDirection: viewMode === 'split' ? 'row' : 'column',
          }}
        >
          {(viewMode === 'dag' || viewMode === 'split') && (
            <div
              className="dag-editor"
              style={{
                width: viewMode === 'split' ? '50%' : '100%',
                height: viewMode === 'dag' ? '100%' : '100%',
              }}
            >
              <DAGEditor />
            </div>
          )}
          {(viewMode === 'code' || viewMode === 'split') && (
            <div
              className="code-editor"
              style={{
                width: viewMode === 'split' ? '50%' : '100%',
                height: viewMode === 'code' ? '100%' : '100%',
              }}
            >
              <CodeEditor
                value={workflowCode}
                onChange={setWorkflowCode}
              />
            </div>
          )}
        </div>

        {showExecutionPanel && (
          <ExecutionPanel
            isRunning={isRunning}
            onPause={handlePause}
            onResume={handleRun}
            onStop={handleStop}
            onReset={handleReset}
          />
        )}
      </div>

      <div className="ide-footer">
        <div className="status">
          <span className={`status-indicator ${isRunning ? 'running' : ''}`} />
          {isRunning ? '运行中' : '就绪'}
        </div>
        <div className="info">
          MoonFlow Studio v0.1.0 | {theme === 'dark' ? '🌙 深色' : '☀️ 浅色'} 主题 | Node.js 20.18.0
        </div>
      </div>

      <WorkflowManager
        onLoad={handleLoadWorkflow}
        onSave={handleSaveWorkflow}
        onExport={handleExport}
        onImport={(file) => {
          const reader = new FileReader();
          reader.onload = (event) => {
            const content = event.target?.result as string;
            setWorkflowCode(content);
            setValidationResult(null);
          };
          reader.readAsText(file);
        }}
        currentWorkflow={{
          id: 'workflow-1',
          name: 'Current Workflow',
          nodeCount: 4,
          edgeCount: 4,
        }}
      />
      <KeyboardShortcutsHelp />
      <AnalyticsDashboard />
    </div>
  );
}
