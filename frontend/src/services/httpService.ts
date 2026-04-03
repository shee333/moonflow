export interface HttpConfig {
  url: string;
  method: 'GET' | 'POST' | 'PUT' | 'DELETE' | 'PATCH' | 'HEAD' | 'OPTIONS';
  headers?: Record<string, string>;
  body?: string | Record<string, unknown>;
  timeout?: number;
  retry?: {
    enabled: boolean;
    maxAttempts: number;
    delayMs: number;
  };
}

export interface HttpResponse {
  status: number;
  statusText: string;
  headers: Record<string, string>;
  body: string;
  responseTime: number;
  size: number;
}

export interface HttpRequestOptions {
  timeout?: number;
  retry?: {
    enabled: boolean;
    maxAttempts: number;
    delayMs: number;
  };
}

const DEFAULT_TIMEOUT = 30000;
const DEFAULT_MAX_ATTEMPTS = 3;
const DEFAULT_DELAY_MS = 1000;

export async function callHttp(
  config: HttpConfig,
  options: HttpRequestOptions = {}
): Promise<HttpResponse> {
  const { timeout = DEFAULT_TIMEOUT, retry } = options;
  const maxAttempts = retry?.enabled ? (retry.maxAttempts || DEFAULT_MAX_ATTEMPTS) : 1;
  const delayMs = retry?.delayMs || DEFAULT_DELAY_MS;

  let lastError: Error | null = null;

  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      const result = await executeRequest(config, timeout);
      
      if (result.status >= 200 && result.status < 300) {
        return result;
      }
      
      if (result.status >= 400 && result.status < 500) {
        throw new Error(`Client Error: ${result.status} ${result.statusText}`);
      }
      
      if (result.status >= 500 && attempt < maxAttempts) {
        lastError = new Error(`Server Error: ${result.status} ${result.statusText}`);
        await sleep(delayMs * attempt);
        continue;
      }
      
      return result;
    } catch (error) {
      lastError = error instanceof Error ? error : new Error(String(error));
      
      if (attempt < maxAttempts) {
        await sleep(delayMs * attempt);
      }
    }
  }

  throw lastError || new Error('HTTP request failed after all retries');
}

async function executeRequest(
  config: HttpConfig,
  timeout: number
): Promise<HttpResponse> {
  const startTime = Date.now();

  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeout);

  try {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
      ...config.headers,
    };

    let body: string | undefined;
    if (config.body) {
      if (typeof config.body === 'string') {
        body = config.body;
      } else {
        body = JSON.stringify(config.body);
      }
    }

    const response = await fetch(config.url, {
      method: config.method,
      headers,
      body: config.method !== 'GET' && config.method !== 'HEAD' ? body : undefined,
      signal: controller.signal,
    });

    clearTimeout(timeoutId);

    const responseHeaders: Record<string, string> = {};
    response.headers.forEach((value, key) => {
      responseHeaders[key] = value;
    });

    const responseBody = await response.text();
    const responseTime = Date.now() - startTime;

    return {
      status: response.status,
      statusText: response.statusText,
      headers: responseHeaders,
      body: responseBody,
      responseTime,
      size: new Blob([responseBody]).size,
    };
  } catch (error) {
    clearTimeout(timeoutId);
    
    if (error instanceof Error) {
      if (error.name === 'AbortError') {
        throw new Error(`Request timeout after ${timeout}ms`);
      }
      throw error;
    }
    
    throw new Error('HTTP request failed: Unknown error');
  }
}

function sleep(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms));
}

export function validateHttpConfig(config: Partial<HttpConfig>): { valid: boolean; errors: string[] } {
  const errors: string[] = [];

  if (!config.url) {
    errors.push('URL is required');
  } else if (!isValidUrl(config.url)) {
    errors.push('Invalid URL format');
  }

  const validMethods = ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'HEAD', 'OPTIONS'];
  if (config.method && !validMethods.includes(config.method.toUpperCase())) {
    errors.push(`Invalid HTTP method. Must be one of: ${validMethods.join(', ')}`);
  }

  if (config.timeout !== undefined && (config.timeout < 0 || config.timeout > 300000)) {
    errors.push('Timeout should be between 0 and 300000ms');
  }

  if (config.retry?.enabled) {
    if (config.retry.maxAttempts < 1 || config.retry.maxAttempts > 10) {
      errors.push('Retry max attempts should be between 1 and 10');
    }
    if (config.retry.delayMs < 0 || config.retry.delayMs > 60000) {
      errors.push('Retry delay should be between 0 and 60000ms');
    }
  }

  return {
    valid: errors.length === 0,
    errors,
  };
}

function isValidUrl(url: string): boolean {
  try {
    const parsed = new URL(url);
    return ['http:', 'https:'].includes(parsed.protocol);
  } catch {
    return false;
  }
}

export function formatHttpResponse(response: HttpResponse): string {
  const lines: string[] = [
    `Status: ${response.status} ${response.statusText}`,
    `Time: ${response.responseTime}ms`,
    `Size: ${formatBytes(response.size)}`,
    '',
    'Headers:',
    ...Object.entries(response.headers).map(([key, value]) => `  ${key}: ${value}`),
    '',
    'Body:',
  ];

  try {
    const jsonBody = JSON.parse(response.body);
    lines.push(JSON.stringify(jsonBody, null, 2));
  } catch {
    lines.push(response.body);
  }

  return lines.join('\n');
}

function formatBytes(bytes: number): string {
  if (bytes < 1024) return `${bytes} B`;
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(2)} KB`;
  return `${(bytes / (1024 * 1024)).toFixed(2)} MB`;
}
