export interface ValidationResult {
  valid: boolean;
  errors: ValidationError[];
  warnings: ValidationWarning[];
}

export interface ValidationError {
  field: string;
  message: string;
}

export interface ValidationWarning {
  field: string;
  message: string;
}

export function validateNodeConfig(
  nodeType: string,
  config: Record<string, any>
): ValidationResult {
  const errors: ValidationError[] = [];
  const warnings: ValidationWarning[] = [];

  switch (nodeType) {
    case 'http':
      validateHttpConfig(config, errors, warnings);
      break;
    case 'llm':
      validateLlmConfig(config, errors, warnings);
      break;
    case 'database':
      validateDatabaseConfig(config, errors, warnings);
      break;
    case 'cache':
      validateCacheConfig(config, errors, warnings);
      break;
    case 'websocket':
      validateWebSocketConfig(config, errors, warnings);
      break;
    case 'grpc':
      validateGrpcConfig(config, errors, warnings);
      break;
    case 'graphql':
      validateGraphQLConfig(config, errors, warnings);
      break;
    case 'response':
      validateResponseConfig(config, errors, warnings);
      break;
    case 'transformer':
      validateTransformerConfig(config, errors, warnings);
      break;
    default:
      warnings.push({
        field: 'type',
        message: `Unknown node type: ${nodeType}. Validation skipped.`,
      });
  }

  return {
    valid: errors.length === 0,
    errors,
    warnings,
  };
}

function validateHttpConfig(
  config: Record<string, any>,
  errors: ValidationError[],
  warnings: ValidationWarning[]
): void {
  if (!config.url) {
    errors.push({
      field: 'url',
      message: 'URL is required for HTTP node',
    });
  } else if (!isValidUrl(config.url)) {
    errors.push({
      field: 'url',
      message: 'Invalid URL format',
    });
  }

  const validMethods = ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'HEAD', 'OPTIONS'];
  if (config.method && !validMethods.includes(config.method.toUpperCase())) {
    errors.push({
      field: 'method',
      message: `Invalid HTTP method. Must be one of: ${validMethods.join(', ')}`,
    });
  }

  if (config.timeout && (config.timeout < 0 || config.timeout > 300000)) {
    warnings.push({
      field: 'timeout',
      message: 'Timeout should be between 0 and 300000ms',
    });
  }
}

function validateLlmConfig(
  config: Record<string, any>,
  errors: ValidationError[],
  warnings: ValidationWarning[]
): void {
  const validModels = [
    'gpt-4',
    'gpt-4-turbo',
    'gpt-3.5-turbo',
    'claude-3-opus',
    'claude-3-sonnet',
    'claude-3-haiku',
    'gemini-pro',
    'gemini-ultra',
  ];

  if (!config.model) {
    warnings.push({
      field: 'model',
      message: 'No model specified. Will use default model.',
    });
  } else if (!validModels.includes(config.model)) {
    warnings.push({
      field: 'model',
      message: `Model "${config.model}" may not be supported. Known models: ${validModels.join(', ')}`,
    });
  }

  if (config.max_tokens && (config.max_tokens < 1 || config.max_tokens > 100000)) {
    warnings.push({
      field: 'max_tokens',
      message: 'max_tokens should be between 1 and 100000',
    });
  }

  if (config.temperature && (config.temperature < 0 || config.temperature > 2)) {
    warnings.push({
      field: 'temperature',
      message: 'Temperature should be between 0 and 2',
    });
  }
}

function validateDatabaseConfig(
  config: Record<string, any>,
  errors: ValidationError[],
  warnings: ValidationWarning[]
): void {
  const validTypes = ['postgresql', 'mysql', 'sqlite', 'mongodb'];
  
  if (!config.type) {
    warnings.push({
      field: 'type',
      message: 'Database type not specified',
    });
  } else if (!validTypes.includes(config.type.toLowerCase())) {
    warnings.push({
      field: 'type',
      message: `Database type "${config.type}" may not be supported. Known types: ${validTypes.join(', ')}`,
    });
  }

  if (!config.query) {
    errors.push({
      field: 'query',
      message: 'SQL query is required',
    });
  }

  if (config.query && isDangerousQuery(config.query)) {
    errors.push({
      field: 'query',
      message: 'Dangerous SQL operations (DROP, DELETE without WHERE) are not allowed',
    });
  }
}

function validateCacheConfig(
  config: Record<string, any>,
  errors: ValidationError[],
  warnings: ValidationWarning[]
): void {
  const validOperations = ['get', 'set', 'delete', 'exists'];
  const validProviders = ['redis', 'memcached', 'memory'];

  if (!config.operation) {
    errors.push({
      field: 'operation',
      message: 'Cache operation is required',
    });
  } else if (!validOperations.includes(config.operation.toLowerCase())) {
    errors.push({
      field: 'operation',
      message: `Invalid operation. Must be one of: ${validOperations.join(', ')}`,
    });
  }

  if (!config.key) {
    errors.push({
      field: 'key',
      message: 'Cache key is required',
    });
  }

  if (!config.provider) {
    warnings.push({
      field: 'provider',
      message: 'Cache provider not specified. Will use default (Redis)',
    });
  } else if (!validProviders.includes(config.provider.toLowerCase())) {
    warnings.push({
      field: 'provider',
      message: `Provider "${config.provider}" may not be supported. Known providers: ${validProviders.join(', ')}`,
    });
  }

  if (config.ttl && (config.ttl < 0 || config.ttl > 86400)) {
    warnings.push({
      field: 'ttl',
      message: 'TTL should be between 0 and 86400 seconds',
    });
  }
}

function validateWebSocketConfig(
  config: Record<string, any>,
  errors: ValidationError[],
  warnings: ValidationWarning[]
): void {
  if (!config.url) {
    errors.push({
      field: 'url',
      message: 'WebSocket URL is required',
    });
  } else if (!isValidWsUrl(config.url)) {
    errors.push({
      field: 'url',
      message: 'Invalid WebSocket URL format. Must start with ws:// or wss://',
    });
  }

  if (config.reconnect_interval && (config.reconnect_interval < 0 || config.reconnect_interval > 60000)) {
    warnings.push({
      field: 'reconnect_interval',
      message: 'Reconnect interval should be between 0 and 60000ms',
    });
  }
}

function validateGrpcConfig(
  config: Record<string, any>,
  errors: ValidationError[],
  warnings: ValidationWarning[]
): void {
  if (!config.service) {
    errors.push({
      field: 'service',
      message: 'gRPC service name is required',
    });
  }

  if (!config.method) {
    errors.push({
      field: 'method',
      message: 'gRPC method name is required',
    });
  }

  if (!config.endpoint) {
    warnings.push({
      field: 'endpoint',
      message: 'gRPC endpoint not specified. Will use default (localhost:50051)',
    });
  } else if (!isValidEndpoint(config.endpoint)) {
    warnings.push({
      field: 'endpoint',
      message: 'Invalid endpoint format. Expected: host:port',
    });
  }
}

function validateGraphQLConfig(
  config: Record<string, any>,
  errors: ValidationError[],
  warnings: ValidationWarning[]
): void {
  if (!config.endpoint) {
    errors.push({
      field: 'endpoint',
      message: 'GraphQL endpoint is required',
    });
  } else if (!isValidUrl(config.endpoint)) {
    errors.push({
      field: 'endpoint',
      message: 'Invalid GraphQL endpoint URL',
    });
  }

  if (!config.query) {
    errors.push({
      field: 'query',
      message: 'GraphQL query is required',
    });
  }

  if (config.variables && typeof config.variables === 'string') {
    try {
      JSON.parse(config.variables);
    } catch (e) {
      errors.push({
        field: 'variables',
        message: 'Invalid JSON format for variables',
      });
    }
  }
}

function validateResponseConfig(
  config: Record<string, any>,
  errors: ValidationError[],
  warnings: ValidationWarning[]
): void {
  if (config.status_code) {
    const statusCode = parseInt(config.status_code);
    if (isNaN(statusCode) || statusCode < 100 || statusCode > 599) {
      errors.push({
        field: 'status_code',
        message: 'Status code must be between 100 and 599',
      });
    }
  }

  if (config.delay && (config.delay < 0 || config.delay > 30000)) {
    warnings.push({
      field: 'delay',
      message: 'Response delay should be between 0 and 30000ms',
    });
  }
}

function validateTransformerConfig(
  config: Record<string, any>,
  errors: ValidationError[],
  warnings: ValidationWarning[]
): void {
  const validTypes = ['map', 'filter', 'reduce', 'flatten', 'custom'];

  if (!config.transform_type) {
    warnings.push({
      field: 'transform_type',
      message: 'Transform type not specified. Will use default (map)',
    });
  } else if (!validTypes.includes(config.transform_type)) {
    warnings.push({
      field: 'transform_type',
      message: `Transform type "${config.transform_type}" may not be supported. Known types: ${validTypes.join(', ')}`,
    });
  }

  if (config.mappings && typeof config.mappings === 'string') {
    try {
      JSON.parse(config.mappings);
    } catch (e) {
      errors.push({
        field: 'mappings',
        message: 'Invalid JSON format for mappings',
      });
    }
  }
}

function isValidUrl(url: string): boolean {
  try {
    const parsed = new URL(url);
    return ['http:', 'https:'].includes(parsed.protocol);
  } catch {
    return false;
  }
}

function isValidWsUrl(url: string): boolean {
  try {
    const parsed = new URL(url);
    return ['ws:', 'wss:'].includes(parsed.protocol);
  } catch {
    return false;
  }
}

function isValidEndpoint(endpoint: string): boolean {
  const pattern = /^[\w.-]+:\d+$/;
  return pattern.test(endpoint);
}

function isDangerousQuery(query: string): boolean {
  const upperQuery = query.toUpperCase().trim();
  return (
    upperQuery.startsWith('DROP ') ||
    upperQuery.startsWith('DELETE ') && !upperQuery.includes('WHERE') ||
    upperQuery.startsWith('TRUNCATE ')
  );
}

export function validateNodeLabel(label: string): ValidationResult {
  const errors: ValidationError[] = [];
  const warnings: ValidationWarning[] = [];

  if (!label || label.trim().length === 0) {
    errors.push({
      field: 'label',
      message: 'Node label cannot be empty',
    });
  } else if (label.length > 100) {
    errors.push({
      field: 'label',
      message: 'Node label cannot exceed 100 characters',
    });
  } else if (!/^[\w\s-]+$/.test(label)) {
    warnings.push({
      field: 'label',
      message: 'Node label should only contain letters, numbers, spaces, and hyphens',
    });
  }

  return {
    valid: errors.length === 0,
    errors,
    warnings,
  };
}
