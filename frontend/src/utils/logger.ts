export enum LogLevel {
  DEBUG = 0,
  INFO = 1,
  WARN = 2,
  ERROR = 3,
}

export interface LogEntry {
  level: LogLevel;
  message: string;
  timestamp: Date;
  context?: Record<string, any>;
}

class Logger {
  private level: LogLevel = LogLevel.INFO;
  private logs: LogEntry[] = [];
  private maxLogs: number = 1000;

  setLevel(level: LogLevel): void {
    this.level = level;
  }

  debug(message: string, context?: Record<string, any>): void {
    this.log(LogLevel.DEBUG, message, context);
  }

  info(message: string, context?: Record<string, any>): void {
    this.log(LogLevel.INFO, message, context);
  }

  warn(message: string, context?: Record<string, any>): void {
    this.log(LogLevel.WARN, message, context);
  }

  error(message: string, context?: Record<string, any>): void {
    this.log(LogLevel.ERROR, message, context);
  }

  private log(level: LogLevel, message: string, context?: Record<string, any>): void {
    if (level < this.level) return;

    const entry: LogEntry = {
      level,
      message,
      timestamp: new Date(),
      context,
    };

    this.logs.push(entry);

    if (this.logs.length > this.maxLogs) {
      this.logs = this.logs.slice(-this.maxLogs);
    }

    const levelName = LogLevel[level];
    const timestamp = entry.timestamp.toISOString();
    const logMessage = `[${timestamp}] [${levelName}] ${message}`;

    switch (level) {
      case LogLevel.DEBUG:
        console.debug(logMessage, context || '');
        break;
      case LogLevel.INFO:
        console.info(logMessage, context || '');
        break;
      case LogLevel.WARN:
        console.warn(logMessage, context || '');
        break;
      case LogLevel.ERROR:
        console.error(logMessage, context || '');
        break;
    }
  }

  getLogs(): LogEntry[] {
    return [...this.logs];
  }

  getLogsByLevel(level: LogLevel): LogEntry[] {
    return this.logs.filter((log) => log.level === level);
  }

  clearLogs(): void {
    this.logs = [];
  }

  exportLogs(): string {
    return JSON.stringify(this.logs, null, 2);
  }
}

export const logger = new Logger();
