import React, { useState, useMemo } from 'react';
import { generateMoonBitCode, validateWorkflow } from '../utils/codeGenerator';
import { useWorkflow } from '../hooks/useWorkflow';
import './CodePreview.css';

export function CodePreview() {
  const { workflow, nodes, edges } = useWorkflow();
  const [isOpen, setIsOpen] = useState(false);
  const [generationOptions, setGenerationOptions] = useState({
    asyncExecution: true,
    errorHandling: true,
    logging: true,
    typeAnnotations: true,
  });

  const { code, validation } = useMemo(() => {
    const currentWorkflow = {
      ...workflow,
      nodes,
      edges,
    };
    
    const validationResult = validateWorkflow(currentWorkflow);
    const codeResult = generateMoonBitCode(currentWorkflow, generationOptions);
    
    return { code: codeResult, validation: validationResult };
  }, [workflow, nodes, edges, generationOptions]);

  const handleDownload = () => {
    const blob = new Blob([code], { type: 'text/plain' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `${workflow.name || 'workflow'}.mbt`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
  };

  const handleCopy = async () => {
    try {
      await navigator.clipboard.writeText(code);
      alert('代码已复制到剪贴板');
    } catch (err) {
      console.error('复制失败:', err);
    }
  };

  if (!isOpen) {
    return (
      <button 
        className="code-preview-toggle"
        onClick={() => setIsOpen(true)}
        title="代码预览"
      >
        <span className="icon">📄</span>
        <span className="label">代码生成</span>
      </button>
    );
  }

  return (
    <div className="code-preview-overlay">
      <div className="code-preview-modal">
        <div className="code-preview-header">
          <h3>MoonBit 代码预览</h3>
          <button 
            className="close-btn"
            onClick={() => setIsOpen(false)}
          >
            ×
          </button>
        </div>

        <div className="code-preview-options">
          <label>
            <input
              type="checkbox"
              checked={generationOptions.asyncExecution}
              onChange={(e) => setGenerationOptions(prev => ({
                ...prev,
                asyncExecution: e.target.checked
              }))}
            />
            异步执行
          </label>
          <label>
            <input
              type="checkbox"
              checked={generationOptions.errorHandling}
              onChange={(e) => setGenerationOptions(prev => ({
                ...prev,
                errorHandling: e.target.checked
              }))}
            />
            错误处理
          </label>
          <label>
            <input
              type="checkbox"
              checked={generationOptions.logging}
              onChange={(e) => setGenerationOptions(prev => ({
                ...prev,
                logging: e.target.checked
              }))}
            />
            日志记录
          </label>
          <label>
            <input
              type="checkbox"
              checked={generationOptions.typeAnnotations}
              onChange={(e) => setGenerationOptions(prev => ({
                ...prev,
                typeAnnotations: e.target.checked
              }))}
            />
            类型注解
          </label>
        </div>

        <div className="code-preview-validation">
          <h4>工作流验证</h4>
          {validation.valid ? (
            <div className="validation-success">
              ✓ 工作流验证通过
            </div>
          ) : (
            <div className="validation-error">
              <ul>
                {validation.errors.map((error, index) => (
                  <li key={index}>{error}</li>
                ))}
              </ul>
            </div>
          )}
        </div>

        <div className="code-preview-content">
          <pre>
            <code>{code}</code>
          </pre>
        </div>

        <div className="code-preview-actions">
          <button 
            className="action-btn copy"
            onClick={handleCopy}
            disabled={!validation.valid}
          >
            复制代码
          </button>
          <button 
            className="action-btn download"
            onClick={handleDownload}
            disabled={!validation.valid}
          >
            下载 .mbt 文件
          </button>
        </div>
      </div>
    </div>
  );
}
