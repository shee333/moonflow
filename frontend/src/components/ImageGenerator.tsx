import { useState } from 'react';
import {
  generateImage,
  MICROSOFT_CULTURE_PRESETS,
  IMAGE_SIZE_OPTIONS,
} from '../utils/imageService';
import type {
  ImageGenerationConfig,
  ImageGenerationRequest,
  ImageGenerationResponse,
} from '../utils/imageService';
import './ImageGenerator.css';

interface ImageGeneratorProps {
  onClose?: () => void;
}

export function ImageGenerator({ onClose }: ImageGeneratorProps) {
  const [config, setConfig] = useState<ImageGenerationConfig>({
    apiKey: '',
    model: 'dall-e-3',
    size: '1024x1024',
    quality: 'standard',
    style: 'vivid',
    n: 1,
  });

  const [request, setRequest] = useState<ImageGenerationRequest>({
    prompt: '',
  });

  const [response, setResponse] = useState<ImageGenerationResponse | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [history, setHistory] = useState<
    Array<{ request: ImageGenerationRequest; response: ImageGenerationResponse; timestamp: Date }>
  >([]);

  const availableSizes = IMAGE_SIZE_OPTIONS.filter((opt) => opt.models.includes(config.model));

  const handleModelChange = (model: ImageGenerationConfig['model']) => {
    const newAvailable = IMAGE_SIZE_OPTIONS.filter((opt) => opt.models.includes(model));
    const sizeStillValid = newAvailable.some((opt) => opt.value === config.size);
    setConfig((prev) => ({
      ...prev,
      model,
      size: sizeStillValid ? prev.size : '1024x1024',
    }));
  };

  const handlePreset = (prompt: string) => {
    setRequest({ prompt });
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    setError(null);
    setResponse(null);

    try {
      const result = await generateImage(config, request);
      setResponse(result);
      setHistory((prev) => [
        { request, response: result, timestamp: new Date() },
        ...prev.slice(0, 9),
      ]);
    } catch (err) {
      setError(err instanceof Error ? err.message : String(err));
    } finally {
      setIsLoading(false);
    }
  };

  const buildFilename = (index: number) => `microsoft-culture-${Date.now()}-${index + 1}.png`;

  const handleDownload = async (url: string, index: number) => {
    const filename = buildFilename(index);
    try {
      const res = await fetch(url);
      const blob = await res.blob();
      const objectUrl = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = objectUrl;
      a.download = filename;
      a.click();
      URL.revokeObjectURL(objectUrl);
    } catch {
      const a = document.createElement('a');
      a.href = url;
      a.target = '_blank';
      a.download = filename;
      a.click();
    }
  };

  return (
    <div className="image-generator">
      <div className="img-gen-header">
        <div className="img-gen-title">
          <span className="img-gen-logo">🖼️</span>
          <div>
            <h3>微软 Culture 图片生成器</h3>
            <p className="img-gen-description">使用 DALL-E AI 生成微软文化价值观相关图片</p>
          </div>
        </div>
        {onClose && (
          <button className="img-gen-close-btn" onClick={onClose} title="关闭">
            ✕
          </button>
        )}
      </div>

      <form onSubmit={handleSubmit} className="img-gen-form">
        <div className="img-gen-section">
          <h4>API 配置</h4>

          <div className="img-gen-form-group">
            <label htmlFor="img-apiKey">OpenAI API 密钥</label>
            <input
              type="password"
              id="img-apiKey"
              value={config.apiKey}
              onChange={(e) => setConfig({ ...config, apiKey: e.target.value })}
              placeholder="输入 OpenAI API 密钥..."
              disabled={isLoading}
            />
            <small>
              <a href="https://platform.openai.com/api-keys" target="_blank" rel="noopener noreferrer">
                获取 OpenAI API 密钥
              </a>
            </small>
          </div>

          <div className="img-gen-form-row">
            <div className="img-gen-form-group">
              <label htmlFor="img-model">模型</label>
              <select
                id="img-model"
                value={config.model}
                onChange={(e) => handleModelChange(e.target.value as ImageGenerationConfig['model'])}
                disabled={isLoading}
              >
                <option value="dall-e-3">DALL-E 3（推荐）</option>
                <option value="dall-e-2">DALL-E 2</option>
              </select>
            </div>

            <div className="img-gen-form-group">
              <label htmlFor="img-size">图片尺寸</label>
              <select
                id="img-size"
                value={config.size}
                onChange={(e) => setConfig({ ...config, size: e.target.value as ImageGenerationConfig['size'] })}
                disabled={isLoading}
              >
                {availableSizes.map((opt) => (
                  <option key={opt.value} value={opt.value}>
                    {opt.label}
                  </option>
                ))}
              </select>
            </div>
          </div>

          {config.model === 'dall-e-3' && (
            <div className="img-gen-form-row">
              <div className="img-gen-form-group">
                <label htmlFor="img-quality">质量</label>
                <select
                  id="img-quality"
                  value={config.quality}
                  onChange={(e) =>
                    setConfig({ ...config, quality: e.target.value as ImageGenerationConfig['quality'] })
                  }
                  disabled={isLoading}
                >
                  <option value="standard">标准</option>
                  <option value="hd">高清 (HD)</option>
                </select>
              </div>

              <div className="img-gen-form-group">
                <label htmlFor="img-style">风格</label>
                <select
                  id="img-style"
                  value={config.style}
                  onChange={(e) =>
                    setConfig({ ...config, style: e.target.value as ImageGenerationConfig['style'] })
                  }
                  disabled={isLoading}
                >
                  <option value="vivid">生动 (Vivid)</option>
                  <option value="natural">自然 (Natural)</option>
                </select>
              </div>
            </div>
          )}

          {config.model === 'dall-e-2' && (
            <div className="img-gen-form-group">
              <label htmlFor="img-n">生成数量 (1-4)</label>
              <input
                type="number"
                id="img-n"
                value={config.n}
                onChange={(e) => setConfig({ ...config, n: Math.min(4, Math.max(1, parseInt(e.target.value) || 1)) })}
                min="1"
                max="4"
                disabled={isLoading}
              />
            </div>
          )}
        </div>

        <div className="img-gen-section">
          <h4>微软 Culture 预设主题</h4>
          <div className="img-gen-presets">
            {MICROSOFT_CULTURE_PRESETS.map((preset) => (
              <button
                key={preset.englishLabel}
                type="button"
                className={`img-gen-preset-btn ${request.prompt === preset.prompt ? 'active' : ''}`}
                onClick={() => handlePreset(preset.prompt)}
                disabled={isLoading}
                title={preset.englishLabel}
              >
                <span className="preset-label">{preset.label}</span>
                <span className="preset-en">{preset.englishLabel}</span>
              </button>
            ))}
          </div>
        </div>

        <div className="img-gen-section">
          <h4>图片描述（Prompt）</h4>
          <div className="img-gen-form-group">
            <textarea
              id="img-prompt"
              value={request.prompt}
              onChange={(e) => setRequest({ prompt: e.target.value })}
              placeholder="描述您想生成的微软文化图片，或从上方选择预设主题..."
              rows={4}
              disabled={isLoading}
            />
            <small>使用英文描述可获得更好效果；点击上方预设可自动填入优化的英文提示词</small>
          </div>
        </div>

        <div className="img-gen-submit-section">
          <button
            type="submit"
            className="img-gen-submit-btn"
            disabled={isLoading || !config.apiKey || !request.prompt.trim()}
          >
            {isLoading ? '⏳ 生成中...' : '🎨 生成图片'}
          </button>
        </div>
      </form>

      {error && (
        <div className="img-gen-error">
          <strong>❌ 错误：</strong> {error}
        </div>
      )}

      {response && (
        <div className="img-gen-result-section">
          <h4>生成结果</h4>
          <div className="img-gen-grid">
            {response.images.map((img, index) => (
              <div key={index} className="img-gen-card">
                <img src={img.url} alt={`生成的微软文化图片 ${index + 1}`} className="img-gen-image" />
                {img.revisedPrompt && (
                  <div className="img-gen-revised-prompt">
                    <strong>优化后的提示词：</strong>
                    <p>{img.revisedPrompt}</p>
                  </div>
                )}
                <div className="img-gen-card-actions">
                  <button
                    className="img-gen-download-btn"
                    onClick={() => handleDownload(img.url, index)}
                    title="下载图片"
                  >
                    ⬇️ 下载
                  </button>
                  <a
                    href={img.url}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="img-gen-open-btn"
                    title="在新标签页打开"
                  >
                    🔗 打开
                  </a>
                </div>
              </div>
            ))}
          </div>
          <div className="img-gen-meta">
            <span>模型：{response.model}</span>
            <span>生成时间：{new Date(response.created * 1000).toLocaleString()}</span>
          </div>
        </div>
      )}

      {history.length > 0 && (
        <div className="img-gen-history-section">
          <div className="img-gen-history-header">
            <h4>历史记录</h4>
            <button className="img-gen-clear-btn" onClick={() => setHistory([])}>
              🗑️ 清空
            </button>
          </div>
          <div className="img-gen-history-list">
            {history.map((item, index) => (
              <div
                key={index}
                className="img-gen-history-item"
                onClick={() => {
                  setRequest(item.request);
                  setResponse(item.response);
                }}
                title="点击恢复此记录"
              >
                <div className="img-gen-history-thumb-row">
                  {item.response.images.slice(0, 2).map((img, i) => (
                    <img
                      key={i}
                      src={img.url}
                      alt="历史记录缩略图"
                      className="img-gen-history-thumb"
                    />
                  ))}
                </div>
                <div className="img-gen-history-info">
                  <div className="img-gen-history-timestamp">{item.timestamp.toLocaleString()}</div>
                  <div className="img-gen-history-prompt">
                    {item.request.prompt.length > 80
                      ? `${item.request.prompt.substring(0, 80)}...`
                      : item.request.prompt}
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
