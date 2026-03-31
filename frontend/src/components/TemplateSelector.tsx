import React, { useState } from 'react';
import { workflowTemplates, getAllCategories, WorkflowTemplate } from '../utils/workflowTemplates';
import './TemplateSelector.css';

interface TemplateSelectorProps {
  onSelect: (template: WorkflowTemplate) => void;
  onClose: () => void;
}

export function TemplateSelector({ onSelect, onClose }: TemplateSelectorProps) {
  const [selectedCategory, setSelectedCategory] = useState<string | null>(null);
  const [selectedTemplate, setSelectedTemplate] = useState<WorkflowTemplate | null>(null);

  const categories = getAllCategories();
  const filteredTemplates = selectedCategory
    ? workflowTemplates.filter((t) => t.category === selectedCategory)
    : workflowTemplates;

  const handleUseTemplate = () => {
    if (selectedTemplate) {
      onSelect(selectedTemplate);
    }
  };

  return (
    <div className="template-selector-overlay" onClick={onClose}>
      <div className="template-selector" onClick={(e) => e.stopPropagation()}>
        <div className="selector-header">
          <h3>选择工作流模板</h3>
          <button className="close-btn" onClick={onClose}>×</button>
        </div>

        <div className="selector-content">
          <div className="category-sidebar">
            <h4>分类</h4>
            <button
              className={`category-btn ${!selectedCategory ? 'active' : ''}`}
              onClick={() => setSelectedCategory(null)}
            >
              📋 全部
            </button>
            {categories.map((category) => (
              <button
                key={category}
                className={`category-btn ${selectedCategory === category ? 'active' : ''}`}
                onClick={() => setSelectedCategory(category)}
              >
                {workflowTemplates.find((t) => t.category === category)?.icon} {category}
              </button>
            ))}
          </div>

          <div className="template-list">
            {filteredTemplates.map((template) => (
              <div
                key={template.id}
                className={`template-card ${selectedTemplate?.id === template.id ? 'selected' : ''}`}
                onClick={() => setSelectedTemplate(template)}
              >
                <div className="template-icon">{template.icon}</div>
                <div className="template-info">
                  <h5>{template.name}</h5>
                  <p>{template.description}</p>
                  <span className="template-category">{template.category}</span>
                </div>
                {selectedTemplate?.id === template.id && (
                  <div className="selected-indicator">✓</div>
                )}
              </div>
            ))}
          </div>

          {selectedTemplate && (
            <div className="template-preview">
              <h4>模板预览</h4>
              <div className="preview-info">
                <div className="info-row">
                  <span className="label">名称:</span>
                  <span className="value">{selectedTemplate.name}</span>
                </div>
                <div className="info-row">
                  <span className="label">描述:</span>
                  <span className="value">{selectedTemplate.description}</span>
                </div>
                <div className="info-row">
                  <span className="label">节点数:</span>
                  <span className="value">{selectedTemplate.workflow.nodes.length}</span>
                </div>
                <div className="info-row">
                  <span className="label">边数:</span>
                  <span className="value">{selectedTemplate.workflow.edges.length}</span>
                </div>
                <div className="node-list">
                  <span className="label">节点:</span>
                  <ul>
                    {selectedTemplate.workflow.nodes.map((node) => (
                      <li key={node.id}>
                        <span className="node-icon">◉</span>
                        {node.label} <small>({node.type})</small>
                      </li>
                    ))}
                  </ul>
                </div>
              </div>
            </div>
          )}
        </div>

        <div className="selector-footer">
          <button className="cancel-btn" onClick={onClose}>
            取消
          </button>
          <button
            className="use-btn"
            onClick={handleUseTemplate}
            disabled={!selectedTemplate}
          >
            使用此模板
          </button>
        </div>
      </div>
    </div>
  );
}

export function TemplateGallery() {
  const [isOpen, setIsOpen] = useState(false);
  const [onSelectCallback, setOnSelectCallback] = useState<((template: WorkflowTemplate) => void) | null>(null);

  const handleSelect = (template: WorkflowTemplate) => {
    if (onSelectCallback) {
      onSelectCallback(template);
    }
    setIsOpen(false);
  };

  if (!isOpen) {
    return (
      <button 
        className="template-gallery-toggle"
        onClick={() => setIsOpen(true)}
        title="工作流模板库"
      >
        <span className="icon">📚</span>
      </button>
    );
  }

  return (
    <TemplateSelector
      onSelect={handleSelect}
      onClose={() => setIsOpen(false)}
    />
  );
}

export function useTemplateSelector(onSelect: (template: WorkflowTemplate) => void) {
  const [isOpen, setIsOpen] = useState(false);

  const TemplateButton = () => (
    <button 
      className="template-gallery-toggle"
      onClick={() => setIsOpen(true)}
      title="工作流模板库"
    >
      <span className="icon">📚</span>
    </button>
  );

  const TemplateModal = () => isOpen ? (
    <TemplateSelector
      onSelect={(template) => {
        onSelect(template);
        setIsOpen(false);
      }}
      onClose={() => setIsOpen(false)}
    />
  ) : null;

  return {
    TemplateButton,
    TemplateModal,
    openTemplateSelector: () => setIsOpen(true),
    closeTemplateSelector: () => setIsOpen(false),
  };
}
