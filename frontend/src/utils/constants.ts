export const NODE_COLORS: Record<string, string> = {
  http: '#007acc',
  websocket: '#00d9ff',
  grpc: '#00ff88',
  graphql: '#e535ab',
  llm: '#9333ea',
  timer: '#f59e0b',
  database: '#27ae60',
  cache: '#f39c12',
  email: '#e74c3c',
  file: '#1abc9c',
  logger: '#95a5a6',
  queue: '#34495e',
  response: '#22c55e',
  filter: '#8e44ad',
  transform: '#d35400',
  aggregator: '#2980b9',
  router: '#c0392b',
  default: '#7f8c8d',
};

export const NODE_ICONS: Record<string, string> = {
  http: '🌐',
  websocket: '🔌',
  grpc: '⚡',
  graphql: '◈',
  llm: '🤖',
  timer: '⏱️',
  database: '🗄️',
  cache: '💾',
  email: '📧',
  file: '📁',
  logger: '📝',
  queue: '📬',
  response: '📤',
  filter: '🔍',
  transform: '🔄',
  aggregator: '⊞',
  router: '🔀',
  default: '⚙️',
};

export const NODE_CATEGORIES: Record<string, string> = {
  http: 'trigger',
  websocket: 'trigger',
  grpc: 'trigger',
  graphql: 'trigger',
  llm: 'processor',
  timer: 'trigger',
  database: 'storage',
  cache: 'storage',
  email: 'notification',
  file: 'storage',
  logger: 'utility',
  queue: 'messaging',
  response: 'output',
  filter: 'processor',
  transform: 'processor',
  aggregator: 'processor',
  router: 'control',
};

export const HTTP_METHODS = ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'HEAD', 'OPTIONS'] as const;

export const LLM_MODELS = [
  'gpt-4',
  'gpt-4-turbo',
  'gpt-3.5-turbo',
  'claude-3-opus',
  'claude-3-sonnet',
  'claude-3-haiku',
  'gemini-pro',
  'gemini-ultra',
] as const;

export const DATABASE_TYPES = ['postgresql', 'mysql', 'sqlite', 'mongodb'] as const;

export const CACHE_OPERATIONS = ['get', 'set', 'delete', 'exists'] as const;

export const CACHE_PROVIDERS = ['redis', 'memcached', 'memory'] as const;

export const TRANSFORM_TYPES = ['map', 'filter', 'reduce', 'flatten', 'custom'] as const;

export const HTTP_STATUS_CODES = {
  OK: 200,
  CREATED: 201,
  NO_CONTENT: 204,
  BAD_REQUEST: 400,
  UNAUTHORIZED: 401,
  FORBIDDEN: 403,
  NOT_FOUND: 404,
  INTERNAL_SERVER_ERROR: 500,
  BAD_GATEWAY: 502,
  SERVICE_UNAVAILABLE: 503,
} as const;

export const ERROR_CODES = {
  VALIDATION_ERROR: 500,
  EXECUTION_ERROR: 501,
  TIMEOUT_ERROR: 502,
  NETWORK_ERROR: 503,
  NOT_FOUND_ERROR: 504,
  AUTHENTICATION_ERROR: 505,
  AUTHORIZATION_ERROR: 506,
  UNKNOWN_ERROR: 507,
} as const;

export const APP_CONFIG = {
  APP_NAME: 'MoonFlow Studio',
  APP_VERSION: '0.1.0',
  MAX_HISTORY_SIZE: 100,
  MAX_NODES: 100,
  MAX_EDGES: 200,
  DEFAULT_TIMEOUT: 30000,
  MAX_ZOOM: 2,
  MIN_ZOOM: 0.1,
} as const;
