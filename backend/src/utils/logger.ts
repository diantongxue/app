export enum LogLevel {
  INFO = 'info',
  WARN = 'warn',
  ERROR = 'error',
}

export interface LogEntry {
  timestamp: string;
  level: LogLevel;
  message: string;
  module?: string;
}

class Logger {
  private logs: LogEntry[] = [];
  private maxLogs: number = 1000;
  private listeners: Set<(logs: LogEntry[]) => void> = new Set();

  private formatTimestamp(): string {
    const now = new Date();
    const dateStr = now.toLocaleString('zh-CN', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit',
    });
    const ms = now.getMilliseconds().toString().padStart(3, '0');
    return `${dateStr}.${ms}`;
  }

  private addLog(level: LogLevel, message: string, module?: string) {
    const log: LogEntry = {
      timestamp: this.formatTimestamp(),
      level,
      message,
      module,
    };

    this.logs.push(log);

    // 限制日志数量
    if (this.logs.length > this.maxLogs) {
      this.logs.shift();
    }

    // 控制台输出
    const prefix = module ? `[${module}]` : '';
    const color = this.getColor(level);
    console.log(`\x1b[${color}m[${log.timestamp}] ${prefix} [${level.toUpperCase()}] ${message}\x1b[0m`);

    // 通知所有监听者
    this.notifyListeners();
  }

  private getColor(level: LogLevel): string {
    switch (level) {
      case LogLevel.ERROR:
        return '31'; // 红色
      case LogLevel.WARN:
        return '33'; // 黄色
      case LogLevel.INFO:
      default:
        return '36'; // 青色
    }
  }

  info(message: string, module?: string) {
    this.addLog(LogLevel.INFO, message, module);
  }

  warn(message: string, module?: string) {
    this.addLog(LogLevel.WARN, message, module);
  }

  error(message: string, module?: string) {
    this.addLog(LogLevel.ERROR, message, module);
  }

  getLogs(): LogEntry[] {
    return [...this.logs];
  }

  clearLogs() {
    this.logs = [];
    this.notifyListeners();
  }

  subscribe(listener: (logs: LogEntry[]) => void) {
    this.listeners.add(listener);
    return () => {
      this.listeners.delete(listener);
    };
  }

  private notifyListeners() {
    this.listeners.forEach(listener => listener(this.getLogs()));
  }
}

export const logger = new Logger();

