import React, { useState } from 'react';
import { getAnalytics, createAnalyticsReport, AnalyticsService } from '../utils/analytics';
import './AnalyticsDashboard.css';

export function AnalyticsDashboard() {
  const [isOpen, setIsOpen] = useState(false);
  const [analytics] = useState<AnalyticsService>(() => getAnalytics());
  const [stats, setStats] = useState(analytics.getStats());

  const handleRefresh = () => {
    setStats(analytics.getStats());
  };

  const handleReset = () => {
    if (confirm('确定要重置所有统计数据吗？')) {
      analytics.resetStats();
      setStats(analytics.getStats());
      alert('统计数据已重置');
    }
  };

  const handleExportReport = () => {
    const report = createAnalyticsReport();
    const blob = new Blob([report], { type: 'text/plain' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `moonflow-stats-${new Date().toISOString().split('T')[0]}.txt`;
    a.click();
    URL.revokeObjectURL(url);
  };

  const topComponents = analytics.getTopComponents(5);

  if (!isOpen) {
    return (
      <button 
        className="analytics-toggle"
        onClick={() => setIsOpen(true)}
        title="使用统计"
      >
        <span className="icon">📊</span>
      </button>
    );
  }

  return (
    <div className="analytics-overlay" onClick={() => setIsOpen(false)}>
      <div className="analytics-panel" onClick={(e) => e.stopPropagation()}>
        <div className="panel-header">
          <h3>使用统计</h3>
          <button className="close-btn" onClick={() => setIsOpen(false)}>×</button>
        </div>

        <div className="panel-content">
          <div className="stats-section">
            <h4>会话信息</h4>
            <div className="stats-grid">
              <div className="stat-item">
                <span className="stat-label">当前会话</span>
                <span className="stat-value">{new Date(stats.sessionStartTime).toLocaleDateString()}</span>
              </div>
              <div className="stat-item">
                <span className="stat-label">总会话数</span>
                <span className="stat-value">{stats.totalSessions}</span>
              </div>
            </div>
          </div>

          <div className="stats-section">
            <h4>工作流</h4>
            <div className="stats-grid">
              <div className="stat-item">
                <span className="stat-label">创建</span>
                <span className="stat-value">{stats.workflowsCreated}</span>
              </div>
              <div className="stat-item">
                <span className="stat-label">保存</span>
                <span className="stat-value">{stats.workflowsSaved}</span>
              </div>
              <div className="stat-item">
                <span className="stat-label">加载</span>
                <span className="stat-value">{stats.workflowsLoaded}</span>
              </div>
            </div>
          </div>

          <div className="stats-section">
            <h4>节点操作</h4>
            <div className="stats-grid">
              <div className="stat-item">
                <span className="stat-label">添加</span>
                <span className="stat-value">
                  {Object.values(stats.nodesAdded).reduce((a, b) => a + b, 0)}
                </span>
              </div>
              <div className="stat-item">
                <span className="stat-label">删除</span>
                <span className="stat-value">{stats.nodesDeleted}</span>
              </div>
            </div>
          </div>

          <div className="stats-section">
            <h4>代码生成</h4>
            <div className="stats-grid">
              <div className="stat-item">
                <span className="stat-label">生成次数</span>
                <span className="stat-value">{stats.codeGenerations}</span>
              </div>
            </div>
          </div>

          {topComponents.length > 0 && (
            <div className="stats-section">
              <h4>最常用组件 Top 5</h4>
              <div className="top-components">
                {topComponents.map((component, index) => (
                  <div key={component.type} className="component-rank">
                    <span className="rank-number">{index + 1}</span>
                    <span className="component-type">{component.type}</span>
                    <span className="component-count">{component.count} 次</span>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>

        <div className="panel-footer">
          <button className="action-btn" onClick={handleRefresh}>
            🔄 刷新
          </button>
          <button className="action-btn" onClick={handleExportReport}>
            📤 导出报告
          </button>
          <button className="action-btn danger" onClick={handleReset}>
            🗑️ 重置
          </button>
        </div>
      </div>
    </div>
  );
}
