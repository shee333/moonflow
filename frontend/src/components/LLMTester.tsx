import { useState } from 'react';
import { callLLM, LLMConfig, LLMRequest, LLMResponse } from '../utils/llmService';
import './LLMTester.css';

interface LLMTesterProps {
  onInsertToWorkflow?: (config: Partial<LLMConfig>, prompt: string) => void;
}

export function LLMTester({ onInsertToWorkflow }: LLMTesterProps) {
  const [config, setConfig] = useState<LLMConfig>({
    provider: 'openai',
    model: 'gpt-3.5-turbo',
    apiKey: '',
    temperature: 0.7,
    maxTokens: 1000,
    systemPrompt: '',
  });

  const [request, setRequest] = useState<LLMRequest>({
    prompt: '',
    systemPrompt: '',
    temperature: 0.7,
    maxTokens: 1000,
  });

  const [response, setResponse] = useState<LLMResponse | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [history, setHistory] = useState<Array<{ request: LLMRequest; response: LLMResponse; timestamp: Date }>>([]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    setError(null);
    setResponse(null);

    try {
      const fullConfig: LLMConfig = {
        ...config,
        systemPrompt: request.systemPrompt || config.systemPrompt,
      };

      const result = await callLLM(fullConfig, request);
      setResponse(result);
      setHistory(prev => [
        { request, response: result, timestamp: new Date() },
        ...prev.slice(0, 9),
      ]);
    } catch (err) {
      setError(err instanceof Error ? err.message : String(err));
    } finally {
      setIsLoading(false);
    }
  };

  const handleInsertToWorkflow = () => {
    if (onInsertToWorkflow) {
      onInsertToWorkflow(config, request.prompt);
    }
  };

  const handleLoadExample = (example: string) => {
    setRequest(prev => ({
      ...prev,
      prompt: example,
    }));
  };

  const clearHistory = () => {
    setHistory([]);
  };

  return (
    <div className="llm-tester">
      <div className="tester-header">
        <h3>🤖 LLM 测试工具</h3>
        <p className="tester-description">
          在不运行整个工作流的情况下测试 LLM 节点配置
        </p>
      </div>

      <form onSubmit={handleSubmit} className="tester-form">
        <div className="config-section">
          <h4>LLM 配置</h4>
          
          <div className="form-group">
            <label htmlFor="provider">提供商</label>
            <select
              id="provider"
              value={config.provider}
              onChange={(e) => setConfig({ ...config, provider: e.target.value as LLMConfig['provider'] })}
              disabled={isLoading}
            >
              <option value="openai">OpenAI</option>
              <option value="claude">Claude (Anthropic)</option>
              <option value="gemini">Google Gemini</option>
            </select>
          </div>

          <div className="form-group">
            <label htmlFor="model">模型</label>
            <input
              type="text"
              id="model"
              value={config.model}
              onChange={(e) => setConfig({ ...config, model: e.target.value })}
              placeholder={getModelPlaceholder(config.provider)}
              disabled={isLoading}
            />
            <small className="model-hint">
              {getModelHint(config.provider)}
            </small>
          </div>

          <div className="form-group">
            <label htmlFor="apiKey">API 密钥</label>
            <input
              type="password"
              id="apiKey"
              value={config.apiKey}
              onChange={(e) => setConfig({ ...config, apiKey: e.target.value })}
              placeholder="输入 API 密钥..."
              disabled={isLoading}
            />
            <small className="api-hint">
              <a href={getApiKeyUrl(config.provider)} target="_blank" rel="noopener noreferrer">
                获取 {config.provider} API 密钥
              </a>
            </small>
          </div>

          <div className="form-row">
            <div className="form-group">
              <label htmlFor="temperature">Temperature</label>
              <input
                type="number"
                id="temperature"
                value={config.temperature}
                onChange={(e) => setConfig({ ...config, temperature: parseFloat(e.target.value) })}
                min="0"
                max="2"
                step="0.1"
                disabled={isLoading}
              />
            </div>

            <div className="form-group">
              <label htmlFor="maxTokens">最大令牌数</label>
              <input
                type="number"
                id="maxTokens"
                value={config.maxTokens}
                onChange={(e) => setConfig({ ...config, maxTokens: parseInt(e.target.value) })}
                min="1"
                max="100000"
                disabled={isLoading}
              />
            </div>
          </div>

          <div className="form-group">
            <label htmlFor="systemPrompt">系统提示词</label>
            <textarea
              id="systemPrompt"
              value={config.systemPrompt}
              onChange={(e) => setConfig({ ...config, systemPrompt: e.target.value })}
              placeholder="定义 AI 的角色和行为..."
              rows={3}
              disabled={isLoading}
            />
          </div>
        </div>

        <div className="request-section">
          <h4>测试请求</h4>

          <div className="form-group">
            <label htmlFor="prompt">用户提示词</label>
            <textarea
              id="prompt"
              value={request.prompt}
              onChange={(e) => setRequest({ ...request, prompt: e.target.value })}
              placeholder="输入您想要测试的提示词..."
              rows={5}
              disabled={isLoading}
            />
          </div>

          <div className="example-prompts">
            <span>示例提示词：</span>
            <button
              type="button"
              onClick={() => handleLoadExample('请介绍一下人工智能的发展历史')}
              disabled={isLoading}
            >
              介绍AI历史
            </button>
            <button
              type="button"
              onClick={() => handleLoadExample('用一句话解释量子计算')}
              disabled={isLoading}
            >
              解释量子计算
            </button>
            <button
              type="button"
              onClick={() => handleLoadExample('给我写一个Python快速排序算法')}
              disabled={isLoading}
            >
              Python代码
            </button>
          </div>
        </div>

        <div className="submit-section">
          <button type="submit" className="submit-btn" disabled={isLoading || !config.apiKey || !request.prompt}>
            {isLoading ? '⏳ 测试中...' : '🧪 测试'}
          </button>

          {response && (
            <button type="button" className="insert-btn" onClick={handleInsertToWorkflow}>
              ➕ 添加到工作流
            </button>
          )}
        </div>
      </form>

      {error && (
        <div className="error-message">
          <strong>❌ 错误：</strong> {error}
        </div>
      )}

      {response && (
        <div className="response-section">
          <h4>响应结果</h4>
          <div className="response-content">
            <div className="response-text">
              <strong>内容：</strong>
              <pre>{response.content}</pre>
            </div>
            <div className="response-meta">
              <div className="meta-item">
                <span className="meta-label">模型：</span>
                <span className="meta-value">{response.model}</span>
              </div>
              <div className="meta-item">
                <span className="meta-label">完成原因：</span>
                <span className="meta-value">{response.finishReason}</span>
              </div>
              <div className="meta-item">
                <span className="meta-label">Token 使用：</span>
                <span className="meta-value">
                  提示词：{response.usage.promptTokens} | 
                  完成：{response.usage.completionTokens} | 
                  总计：{response.usage.totalTokens}
                </span>
              </div>
            </div>
          </div>
        </div>
      )}

      {history.length > 0 && (
        <div className="history-section">
          <div className="history-header">
            <h4>历史记录</h4>
            <button className="clear-history-btn" onClick={clearHistory}>
              🗑️ 清空
            </button>
          </div>
          <div className="history-list">
            {history.map((item, index) => (
              <div key={index} className="history-item">
                <div className="history-timestamp">
                  {item.timestamp.toLocaleString()}
                </div>
                <div className="history-prompt">
                  <strong>提示词：</strong>
                  <span>{item.request.prompt.substring(0, 100)}...</span>
                </div>
                <div className="history-response">
                  <strong>响应：</strong>
                  <span>{item.response.content.substring(0, 100)}...</span>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}

function getModelPlaceholder(provider: string): string {
  switch (provider) {
    case 'openai':
      return 'gpt-4, gpt-4-turbo, gpt-3.5-turbo';
    case 'claude':
      return 'claude-3-opus, claude-3-sonnet, claude-3-haiku';
    case 'gemini':
      return 'gemini-pro, gemini-1.5-pro';
    default:
      return 'model-name';
  }
}

function getModelHint(provider: string): string {
  switch (provider) {
    case 'openai':
      return '推荐：gpt-3.5-turbo（性价比高）或 gpt-4（高质量）';
    case 'claude':
      return '推荐：claude-3-haiku（快速）或 claude-3-opus（最智能）';
    case 'gemini':
      return '推荐：gemini-pro（通用）或 gemini-1.5-pro（长上下文）';
    default:
      return '';
  }
}

function getApiKeyUrl(provider: string): string {
  switch (provider) {
    case 'openai':
      return 'https://platform.openai.com/api-keys';
    case 'claude':
      return 'https://console.anthropic.com/settings/keys';
    case 'gemini':
      return 'https://makersuite.google.com/app/apikey';
    default:
      return '#';
  }
}
