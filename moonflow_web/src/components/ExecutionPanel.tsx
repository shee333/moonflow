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
      addLog('info', '工作流执行已开始');
      
      const interval = setInterval(() => {
        const progress = Math.random();
        if (progress > 0.9) {
          addLog('success', '节点执行成功');
        } else if (progress > 0.7) {
          addLog('info', '处理中...');
        }
      }, 2000);

      setTimeout(() => {
        clearInterval(interval);
        setStatus('completed');
        addLog('success', '工作流执行完成');
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
      addLog('warning', '工作流执行已暂停');
      onPause();
    }
  };

  const handleResume = () => {
    if (status === 'paused') {
      setStatus('running');
      addLog('info', '工作流执行已恢复');
      onStart();
    }
  };

  const handleStop = () => {
    setStatus('idle');
    addLog('error', '工作流执行已停止');
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
        return '就绪';
      case 'running':
        return '运行中';
      case 'paused':
        return '已暂停';
      case 'completed':
        return '已完成';
      case 'error':
        return '错误';
      default:
        return '未知';
    }
  };

  const getStatusClass = () => {
    return `execution-panel ${status}`;
  };

  return (
    <div className={getStatusClass()}>
      <div className="panel-section">
        <h3>执行状态</h3>
        <div className="status-display">
          <span className={`status-indicator ${status}`}></span>
          <span className="status-text">{getStatusText()}</span>
        </div>
      </div>

      <div className="panel-section">
        <h3>控制面板</h3>
        <div className="control-buttons">
          {status === 'idle' && (
            <button className="control-btn start" onClick={onStart}>
              ▶️ 开始
            </button>
          )}
          {status === 'running' && (
            <>
              <button className="control-btn pause" onClick={handlePause}>
                ⏸️ 暂停
              </button>
              <button className="control-btn stop" onClick={handleStop}>
                ⏹️ 停止
              </button>
            </>
          )}
          {status === 'paused' && (
            <>
              <button className="control-btn resume" onClick={handleResume}>
                ▶️ 继续
              </button>
              <button className="control-btn stop" onClick={handleStop}>
                ⏹️ 停止
              </button>
            </>
          )}
          {status === 'completed' && (
            <button className="control-btn reset" onClick={handleReset}>
              🔄 重置
            </button>
          )}
        </div>
      </div>

      <div className="panel-section logs-section">
        <h3>执行日志</h3>
        <div className="logs-container">
          {logs.length === 0 ? (
            <div className="empty-logs">暂无日志。开始执行工作流以查看日志。</div>
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
