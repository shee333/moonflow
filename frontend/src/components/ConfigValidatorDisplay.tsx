import React from 'react';
import { validateNodeConfig, validateNodeLabel, ValidationResult } from '../utils/nodeValidator';
import './ConfigValidatorDisplay.css';

interface ConfigValidatorDisplayProps {
  nodeType: string;
  config: Record<string, any>;
  label?: string;
}

export function ConfigValidatorDisplay({ nodeType, config, label }: ConfigValidatorDisplayProps) {
  const labelValidation = label !== undefined ? validateNodeLabel(label) : null;
  const configValidation = validateNodeConfig(nodeType, config);
  
  const hasIssues = 
    (labelValidation && !labelValidation.valid) ||
    !configValidation.valid ||
    configValidation.warnings.length > 0 ||
    (labelValidation && labelValidation.warnings.length > 0);

  if (!hasIssues) {
    return (
      <div className="config-validator-display valid">
        <span className="icon">✓</span>
        <span className="message">配置有效</span>
      </div>
    );
  }

  return (
    <div className="config-validator-display issues">
      {labelValidation && !labelValidation.valid && (
        <div className="validation-section errors">
          <h5>标签错误</h5>
          <ul>
            {labelValidation.errors.map((error, index) => (
              <li key={`label-error-${index}`}>
                <span className="field">{error.field}:</span> {error.message}
              </li>
            ))}
          </ul>
        </div>
      )}

      {!configValidation.valid && (
        <div className="validation-section errors">
          <h5>配置错误</h5>
          <ul>
            {configValidation.errors.map((error, index) => (
              <li key={`config-error-${index}`}>
                <span className="field">{error.field}:</span> {error.message}
              </li>
            ))}
          </ul>
        </div>
      )}

      {(labelValidation?.warnings.length || configValidation.warnings.length) > 0 && (
        <div className="validation-section warnings">
          <h5>警告</h5>
          <ul>
            {labelValidation?.warnings.map((warning, index) => (
              <li key={`label-warning-${index}`}>
                <span className="field">{warning.field}:</span> {warning.message}
              </li>
            ))}
            {configValidation.warnings.map((warning, index) => (
              <li key={`config-warning-${index}`}>
                <span className="field">{warning.field}:</span> {warning.message}
              </li>
            ))}
          </ul>
        </div>
      )}
    </div>
  );
}

export function useNodeValidation(nodeType: string, config: Record<string, any>, label?: string) {
  const labelValidation = label !== undefined ? validateNodeLabel(label) : null;
  const configValidation = validateNodeConfig(nodeType, config);
  
  const isValid = 
    (!labelValidation || labelValidation.valid) &&
    configValidation.valid;
  
  const issuesCount = 
    (labelValidation?.errors.length || 0) +
    configValidation.errors.length +
    (labelValidation?.warnings.length || 0) +
    configValidation.warnings.length;

  return {
    isValid,
    issuesCount,
    labelValidation,
    configValidation,
  };
}
