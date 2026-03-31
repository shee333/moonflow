export interface LLMConfig {
  provider: 'openai' | 'claude' | 'gemini';
  model: string;
  apiKey: string;
  temperature: number;
  maxTokens: number;
  systemPrompt?: string;
}

export interface LLMRequest {
  prompt: string;
  systemPrompt?: string;
  temperature?: number;
  maxTokens?: number;
}

export interface LLMResponse {
  content: string;
  model: string;
  usage: {
    promptTokens: number;
    completionTokens: number;
    totalTokens: number;
  };
  finishReason: string;
}

export async function callLLM(config: LLMConfig, request: LLMRequest): Promise<LLMResponse> {
  const { provider, model, apiKey, temperature, maxTokens, systemPrompt } = config;
  const { prompt } = request;

  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
  };

  let endpoint = '';
  let body: Record<string, any> = {};

  switch (provider) {
    case 'openai':
      headers['Authorization'] = `Bearer ${apiKey}`;
      endpoint = `https://api.openai.com/v1/chat/completions`;
      body = {
        model: model || 'gpt-3.5-turbo',
        messages: [
          ...(systemPrompt ? [{ role: 'system', content: systemPrompt }] : []),
          { role: 'user', content: prompt },
        ],
        temperature: temperature ?? 0.7,
        max_tokens: maxTokens ?? 1000,
      };
      break;

    case 'claude':
      headers['x-api-key'] = apiKey;
      headers['anthropic-version'] = '2023-06-01';
      endpoint = `https://api.anthropic.com/v1/messages`;
      body = {
        model: model || 'claude-3-haiku-20240307',
        messages: [{ role: 'user', content: prompt }],
        max_tokens: maxTokens ?? 1024,
        ...(systemPrompt && { system: systemPrompt }),
      };
      break;

    case 'gemini':
      headers['Authorization'] = `Bearer ${apiKey}`;
      endpoint = `https://generativelanguage.googleapis.com/v1beta/models/${model || 'gemini-pro'}:generateContent?key=${apiKey}`;
      body = {
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: {
          temperature: temperature ?? 0.7,
          maxOutputTokens: maxTokens ?? 1024,
        },
        ...(systemPrompt && { systemInstruction: { parts: [{ text: systemPrompt }] } }),
      };
      break;
  }

  try {
    const response = await fetch(endpoint, {
      method: 'POST',
      headers,
      body: JSON.stringify(body),
    });

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}));
      throw new Error(errorData.error?.message || `API request failed with status ${response.status}`);
    }

    const data = await response.json();

    switch (provider) {
      case 'openai':
        return {
          content: data.choices[0]?.message?.content || '',
          model: data.model,
          usage: {
            promptTokens: data.usage?.prompt_tokens || 0,
            completionTokens: data.usage?.completion_tokens || 0,
            totalTokens: data.usage?.total_tokens || 0,
          },
          finishReason: data.choices[0]?.finish_reason || 'stop',
        };

      case 'claude':
        return {
          content: data.content?.[0]?.text || '',
          model: data.model || model,
          usage: {
            promptTokens: data.usage?.input_tokens || 0,
            completionTokens: data.usage?.output_tokens || 0,
            totalTokens: (data.usage?.input_tokens || 0) + (data.usage?.output_tokens || 0),
          },
          finishReason: 'stop',
        };

      case 'gemini':
        return {
          content: data.candidates?.[0]?.content?.parts?.[0]?.text || '',
          model: model || 'gemini-pro',
          usage: {
            promptTokens: data.usage?.promptTokenCount || 0,
            completionTokens: data.usage?.candidatesTokenCount || 0,
            totalTokens: data.usage?.totalTokenCount || 0,
          },
          finishReason: data.candidates?.[0]?.finishReason || 'STOP',
        };
    }
  } catch (error) {
    if (error instanceof Error) {
      throw new Error(`LLM API调用失败: ${error.message}`);
    }
    throw new Error('LLM API调用失败: 未知错误');
  }
}

export function validateLLMConfig(config: Partial<LLMConfig>): { valid: boolean; errors: string[] } {
  const errors: string[] = [];

  if (!config.provider) {
    errors.push('请选择 LLM 提供商');
  }

  if (!config.apiKey || config.apiKey.trim() === '') {
    errors.push('请输入 API Key');
  }

  if (!config.model || config.model.trim() === '') {
    errors.push('请输入模型名称');
  }

  if (config.temperature !== undefined) {
    if (config.temperature < 0 || config.temperature > 2) {
      errors.push('Temperature 应该在 0-2 之间');
    }
  }

  if (config.maxTokens !== undefined) {
    if (config.maxTokens < 1 || config.maxTokens > 32000) {
      errors.push('Max Tokens 应该在 1-32000 之间');
    }
  }

  return {
    valid: errors.length === 0,
    errors,
  };
}

export function getModelOptions(provider: 'openai' | 'claude' | 'gemini'): string[] {
  switch (provider) {
    case 'openai':
      return [
        'gpt-4o',
        'gpt-4o-mini',
        'gpt-4-turbo',
        'gpt-4',
        'gpt-3.5-turbo',
        'o1-preview',
        'o1-mini',
      ];
    case 'claude':
      return [
        'claude-3-5-sonnet-20241022',
        'claude-3-5-sonnet-latest',
        'claude-3-opus-20240229',
        'claude-3-sonnet-20240229',
        'claude-3-haiku-20240307',
      ];
    case 'gemini':
      return [
        'gemini-2.0-flash-exp',
        'gemini-1.5-flash',
        'gemini-1.5-flash-8b',
        'gemini-1.5-pro',
        'gemini-1.0-pro',
      ];
    default:
      return [];
  }
}
