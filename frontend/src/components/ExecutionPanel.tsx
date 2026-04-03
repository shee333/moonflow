import { useRef, useEffect } from 'react';
import './ExecutionPanel.css';

export type ExecutionStatus = 'idle' | 'running' | 'paused' | 'completed' | 'failed' | 'error';

export interface ExecutionLog {
  id: string;
  timestamp: number;
  type: 'info' | 'warning' | 'error' | 'success';
  message: string;
  nodeId?: string;
  data?: unknown;
}

export type NodeData = {
  label?: string;
  type?: string;
  [key: string]: unknown;
};

interface ExecutionPanelProps {
  isRunning: boolean;
  onStart?: () => void;
  onPause?: () => void;
  onStop?: () => void;
  onReset?: () => void;
  logs?: ExecutionLog[];
  status?: ExecutionStatus;
}

export function ExecutionPanel({
  onStart,
  onPause: _onPause,
  onStop,
  onReset,
  logs = [],
  status = 'idle',
}: ExecutionPanelProps) {
  void _onPause;
  const logsEndRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (logsEndRef.current) {
      logsEndRef.current.scrollIntoView({ behavior: 'smooth' });
    }
  }, [logs.length]);

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
      case 'failed':
      case 'error':
        return '执行失败';
      default:
        return '未知';
    }
  };

  const getStatusClass = () => {
    return `execution-panel ${status}`;
  };

  const formatTimestamp = (ts: number) => {
    const date = new Date(ts);
    return date.toLocaleTimeString('zh-CN', { hour12: false });
  };

  const getLogIcon = (type: ExecutionLog['type']) => {
    switch (type) {
      case 'success':
        return '✅';
      case 'error':
        return '❌';
      case 'warning':
        return '⚠️';
      default:
        return 'ℹ️';
    }
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
          {(status === 'idle' || status === 'completed' || status === 'failed') && (
            <button className="control-btn start" onClick={onStart}>
              ▶️ 运行
            </button>
          )}
          {status === 'running' && (
            <button className="control-btn stop" onClick={onStop}>
              ⏹️ 停止
            </button>
          )}
          {(status === 'completed' || status === 'failed') && (
            <button className="control-btn reset" onClick={onReset}>
              🔄 重置
            </button>
          )}
        </div>
      </div>

      <div className="panel-section logs-section">
        <h3>执行日志</h3>
        <div className="logs-container">
          {logs.length === 0 ? (
            <div className="empty-logs">暂无日志。点击"运行"开始执行工作流。</div>
          ) : (
            <>
              {logs.map((log) => (
                <div key={log.id} className={`log-entry ${log.type}`}>
                  <span className="log-icon">{getLogIcon(log.type)}</span>
                  <span className="log-timestamp">{formatTimestamp(log.timestamp)}</span>
                  {log.nodeId && <span className="log-node">[{log.nodeId}]</span>}
                  <span className="log-message">{log.message}</span>
                </div>
              ))}
              <div ref={logsEndRef} />
            </>
          )}
        </div>
      </div>
    </div>
  );
}
