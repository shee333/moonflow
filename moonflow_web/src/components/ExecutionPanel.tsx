import { useState, useEffect } from 'react';
import './ExecutionPanel.css';

export type ExecutionStatus = 'idle' | 'running' | 'paused' | 'completed' | 'error';

export interface ExecutionLog {
  id: number;
  timestamp: string;
  level: 'info' | 'warning' | 'error' | 'success';
  message: string;
  nodeId?: string;
}

interface ExecutionPanelProps {
  isRunning: boolean;
  onStart: () => void;
  onPause: () => void;
  onStop: () => void;
  onReset: () => void;
}

export function ExecutionPanel({
  isRunning,
  onStart,
  onPause,
  onStop,
  onReset,
}: ExecutionPanelProps) {
  const [status, setStatus] = useState<ExecutionStatus>('idle');
  const [logs, setLogs] = useState<ExecutionLog[]>([]);
  const [logIdCounter, setLogIdCounter] = useState(0);

  useEffect(() => {
    if (isRunning && status === 'idle') {
      setStatus('running');
      addLog('info', 'Workflow execution started');
      
      const interval = setInterval(() => {
        const progress = Math.random();
        if (progress > 0.9) {
          addLog('success', 'Node completed successfully');
        } else if (progress > 0.7) {
          addLog('info', 'Processing...');
        }
      }, 2000);

      setTimeout(() => {
        clearInterval(interval);
        setStatus('completed');
        addLog('success', 'Workflow execution completed');
      }, 10000);

      return () => clearInterval(interval);
    }
  }, [isRunning, status]);

  const addLog = (level: ExecutionLog['level'], message: string, nodeId?: string) => {
    const newLog: ExecutionLog = {
      id: logIdCounter,
      timestamp: new Date().toLocaleTimeString(),
      level,
      message,
      nodeId,
    };
    setLogs((prev) => [...prev, newLog]);
    setLogIdCounter((prev) => prev + 1);
  };

  const handlePause = () => {
    if (status === 'running') {
      setStatus('paused');
      addLog('warning', 'Workflow execution paused');
      onPause();
    }
  };

  const handleResume = () => {
    if (status === 'paused') {
      setStatus('running');
      addLog('info', 'Workflow execution resumed');
      onStart();
    }
  };

  const handleStop = () => {
    setStatus('idle');
    addLog('error', 'Workflow execution stopped');
    onStop();
  };

  const handleReset = () => {
    setStatus('idle');
    setLogs([]);
    onReset();
  };

  const getStatusText = () => {
    switch (status) {
      case 'idle':
        return 'Ready';
      case 'running':
        return 'Running';
      case 'paused':
        return 'Paused';
      case 'completed':
        return 'Completed';
      case 'error':
        return 'Error';
      default:
        return 'Unknown';
    }
  };

  const getStatusClass = () => {
    return `execution-panel ${status}`;
  };

  return (
    <div className={getStatusClass()}>
      <div className="panel-section">
        <h3>Execution Status</h3>
        <div className="status-display">
          <span className={`status-indicator ${status}`}></span>
          <span className="status-text">{getStatusText()}</span>
        </div>
      </div>

      <div className="panel-section">
        <h3>Controls</h3>
        <div className="control-buttons">
          {status === 'idle' && (
            <button className="control-btn start" onClick={onStart}>
              ▶️ Start
            </button>
          )}
          {status === 'running' && (
            <>
              <button className="control-btn pause" onClick={handlePause}>
                ⏸️ Pause
              </button>
              <button className="control-btn stop" onClick={handleStop}>
                ⏹️ Stop
              </button>
            </>
          )}
          {status === 'paused' && (
            <>
              <button className="control-btn resume" onClick={handleResume}>
                ▶️ Resume
              </button>
              <button className="control-btn stop" onClick={handleStop}>
                ⏹️ Stop
              </button>
            </>
          )}
          {status === 'completed' && (
            <button className="control-btn reset" onClick={handleReset}>
              🔄 Reset
            </button>
          )}
        </div>
      </div>

      <div className="panel-section logs-section">
        <h3>Execution Logs</h3>
        <div className="logs-container">
          {logs.length === 0 ? (
            <div className="empty-logs">No logs yet. Start the workflow to see execution logs.</div>
          ) : (
            logs.map((log) => (
              <div key={log.id} className={`log-entry ${log.level}`}>
                <span className="log-timestamp">{log.timestamp}</span>
                <span className="log-level">[{log.level.toUpperCase()}]</span>
                <span className="log-message">{log.message}</span>
              </div>
            ))
          )}
        </div>
      </div>
    </div>
  );
}
