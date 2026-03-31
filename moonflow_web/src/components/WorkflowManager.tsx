import React, { useState, useRef, useEffect } from 'react';
import './WorkflowManager.css';

interface WorkflowMetadata {
  id: string;
  name: string;
  description: string;
  version: string;
  createdAt: string;
  updatedAt: string;
  nodeCount: number;
  edgeCount: number;
}

interface WorkflowManagerProps {
  onLoad: (workflowId: string) => void;
  onSave: (name: string, description: string) => void;
  onExport: () => void;
  onImport: (file: File) => void;
  currentWorkflow?: {
    id: string;
    name: string;
    nodeCount: number;
    edgeCount: number;
  };
}

const STORAGE_KEY = 'moonflow_workflows';

export function WorkflowManager({ 
  onLoad, 
  onSave, 
  onExport, 
  onImport,
  currentWorkflow 
}: WorkflowManagerProps) {
  const [isOpen, setIsOpen] = useState(false);
  const [savedWorkflows, setSavedWorkflows] = useState<WorkflowMetadata[]>([]);
  const [showSaveDialog, setShowSaveDialog] = useState(false);
  const [workflowName, setWorkflowName] = useState('');
  const [workflowDescription, setWorkflowDescription] = useState('');
  const [activeTab, setActiveTab] = useState<'load' | 'save'>('load');
  const fileInputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    const stored = localStorage.getItem(STORAGE_KEY);
    if (stored) {
      try {
        const workflows = JSON.parse(stored);
        setSavedWorkflows(workflows);
      } catch (e) {
        console.error('Failed to parse saved workflows:', e);
      }
    }
  }, [isOpen]);

  const handleSave = () => {
    if (!workflowName.trim()) {
      alert('请输入工作流名称');
      return;
    }

    const workflow: WorkflowMetadata = {
      id: currentWorkflow?.id || `workflow-${Date.now()}`,
      name: workflowName.trim(),
      description: workflowDescription.trim(),
      version: '1.0.0',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
      nodeCount: currentWorkflow?.nodeCount || 0,
      edgeCount: currentWorkflow?.edgeCount || 0,
    };

    const updated = [workflow, ...savedWorkflows.filter(w => w.id !== workflow.id)];
    setSavedWorkflows(updated);
    localStorage.setItem(STORAGE_KEY, JSON.stringify(updated));
    
    onSave(workflow.name, workflow.description);
    setShowSaveDialog(false);
    setWorkflowName('');
    setWorkflowDescription('');
  };

  const handleLoad = (workflowId: string) => {
    onLoad(workflowId);
    setIsOpen(false);
  };

  const handleDelete = (workflowId: string) => {
    if (confirm('确定要删除这个工作流吗？')) {
      const updated = savedWorkflows.filter(w => w.id !== workflowId);
      setSavedWorkflows(updated);
      localStorage.setItem(STORAGE_KEY, JSON.stringify(updated));
    }
  };

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      onImport(file);
      setIsOpen(false);
    }
  };

  if (!isOpen) {
    return (
      <button 
        className="workflow-manager-toggle"
        onClick={() => setIsOpen(true)}
        title="管理工作流"
      >
        <span className="icon">📁</span>
      </button>
    );
  }

  return (
    <div className="workflow-manager-overlay">
      <div className="workflow-manager">
        <div className="manager-header">
          <h3>工作流管理</h3>
          <button className="close-btn" onClick={() => setIsOpen(false)}>×</button>
        </div>

        <div className="manager-tabs">
          <button 
            className={`tab ${activeTab === 'load' ? 'active' : ''}`}
            onClick={() => setActiveTab('load')}
          >
            加载工作流
          </button>
          <button 
            className={`tab ${activeTab === 'save' ? 'active' : ''}`}
            onClick={() => setActiveTab('save')}
          >
            保存当前
          </button>
        </div>

        <div className="manager-content">
          {activeTab === 'load' && (
            <div className="load-section">
              {savedWorkflows.length === 0 ? (
                <div className="empty-state">
                  <span className="icon">📭</span>
                  <p>暂无保存的工作流</p>
                  <small>保存当前工作流后将显示在这里</small>
                </div>
              ) : (
                <div className="workflow-list">
                  {savedWorkflows.map((workflow) => (
                    <div key={workflow.id} className="workflow-item">
                      <div className="workflow-info">
                        <h4>{workflow.name}</h4>
                        {workflow.description && (
                          <p className="description">{workflow.description}</p>
                        )}
                        <div className="workflow-meta">
                          <span>📊 {workflow.nodeCount} 节点</span>
                          <span>🔗 {workflow.edgeCount} 边</span>
                          <span>🕐 {new Date(workflow.updatedAt).toLocaleDateString()}</span>
                        </div>
                      </div>
                      <div className="workflow-actions">
                        <button 
                          className="load-btn"
                          onClick={() => handleLoad(workflow.id)}
                        >
                          加载
                        </button>
                        <button 
                          className="delete-btn"
                          onClick={() => handleDelete(workflow.id)}
                        >
                          删除
                        </button>
                      </div>
                    </div>
                  ))}
                </div>
              )}

              <div className="import-section">
                <h4>导入/导出</h4>
                <div className="import-export-buttons">
                  <button className="action-btn" onClick={onExport}>
                    📤 导出当前工作流
                  </button>
                  <button 
                    className="action-btn"
                    onClick={() => fileInputRef.current?.click()}
                  >
                    📥 导入工作流文件
                  </button>
                  <input
                    ref={fileInputRef}
                    type="file"
                    accept=".json"
                    onChange={handleFileChange}
                    style={{ display: 'none' }}
                  />
                </div>
              </div>
            </div>
          )}

          {activeTab === 'save' && (
            <div className="save-section">
              <div className="form-group">
                <label>工作流名称 *</label>
                <input
                  type="text"
                  value={workflowName}
                  onChange={(e) => setWorkflowName(e.target.value)}
                  placeholder="输入工作流名称"
                  className="form-input"
                />
              </div>

              <div className="form-group">
                <label>描述</label>
                <textarea
                  value={workflowDescription}
                  onChange={(e) => setWorkflowDescription(e.target.value)}
                  placeholder="描述此工作流的功能（可选）"
                  className="form-textarea"
                  rows={3}
                />
              </div>

              {currentWorkflow && (
                <div className="current-info">
                  <h4>当前工作流信息</h4>
                  <p>名称: {currentWorkflow.name}</p>
                  <p>节点数: {currentWorkflow.nodeCount}</p>
                  <p>边数: {currentWorkflow.edgeCount}</p>
                </div>
              )}

              <button className="save-btn" onClick={handleSave}>
                💾 保存工作流
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
