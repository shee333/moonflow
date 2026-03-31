import React, { useState, useEffect } from 'react';
import { performanceMonitor, PerformanceMetric } from '../utils/performance';
import './PerformanceMonitor.css';

export function PerformanceMonitor() {
  const [isOpen, setIsOpen] = useState(false);
  const [metrics, setMetrics] = useState<PerformanceMetric[]>([]);
  const [memory, setMemory] = useState<{ used: number; total: number; percentage: number } | null>(null);

  useEffect(() => {
    if (isOpen) {
      const interval = setInterval(() => {
        setMetrics(performanceMonitor.getMetrics().slice(-20));
        setMemory(performanceMonitor.getMemoryUsage());
      }, 1000);

      return () => clearInterval(interval);
    }
  }, [isOpen]);

  const handleClear = () => {
    performanceMonitor.clearMetrics();
    setMetrics([]);
  };

  const handleExport = () => {
    const report = performanceMonitor.getReport();
    const blob = new Blob([JSON.stringify(report, null, 2)], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `performance-report-${new Date().toISOString()}.json`;
    a.click();
    URL.revokeObjectURL(url);
  };

  const renderMetrics = metrics.filter((m) => m.name.includes('render'));
  const avgRenderTime = renderMetrics.length > 0
    ? renderMetrics.reduce((acc, m) => acc + m.value, 0) / renderMetrics.length
    : 0;

  if (!isOpen) {
    return (
      <button 
        className="performance-toggle"
        onClick={() => setIsOpen(true)}
        title="性能监控"
      >
        <span className="icon">⚡</span>
        {memory && memory.percentage > 70 && (
          <span className="warning-badge">!</span>
        )}
      </button>
    );
  }

  return (
    <div className="performance-overlay" onClick={() => setIsOpen(false)}>
      <div className="performance-panel" onClick={(e) => e.stopPropagation()}>
        <div className="panel-header">
          <h3>性能监控</h3>
          <button className="close-btn" onClick={() => setIsOpen(false)}>×</button>
        </div>

        <div className="panel-content">
          {memory && (
            <div className="memory-section">
              <h4>内存使用</h4>
              <div className="memory-bar">
                <div 
                  className="memory-fill"
                  style={{ 
                    width: `${memory.percentage}%`,
                    backgroundColor: memory.percentage > 80 ? '#e74c3c' : 
                                   memory.percentage > 60 ? '#f39c12' : '#27ae60'
                  }}
                />
              </div>
              <div className="memory-stats">
                <span>{memory.used} MB / {memory.total} MB</span>
                <span className="percentage">{memory.percentage}%</span>
              </div>
            </div>
          )}

          <div className="stats-section">
            <h4>渲染性能</h4>
            <div className="stats-grid">
              <div className="stat-item">
                <span className="stat-label">平均渲染时间</span>
                <span className="stat-value" style={{ color: avgRenderTime > 50 ? '#e74c3c' : '#27ae60' }}>
                  {avgRenderTime.toFixed(2)} ms
                </span>
              </div>
              <div className="stat-item">
                <span className="stat-label">最近指标数</span>
                <span className="stat-value">{metrics.length}</span>
              </div>
            </div>
          </div>

          <div className="metrics-section">
            <h4>最近活动</h4>
            <div className="metrics-list">
              {metrics.length === 0 ? (
                <div className="empty-state">暂无性能数据</div>
              ) : (
                metrics.map((metric, index) => (
                  <div key={index} className="metric-item">
                    <span className="metric-name">{metric.name.split(':')[1]}</span>
                    <span className="metric-value">
                      {metric.value.toFixed(2)} {metric.unit}
                    </span>
                  </div>
                ))
              )}
            </div>
          </div>
        </div>

        <div className="panel-footer">
          <button className="action-btn" onClick={handleClear}>
            🗑️ 清除
          </button>
          <button className="action-btn" onClick={handleExport}>
            📤 导出报告
          </button>
          <button className="action-btn" onClick={() => performanceMonitor.logPerformanceSummary()}>
            📊 输出到控制台
          </button>
        </div>
      </div>
    </div>
  );
}
