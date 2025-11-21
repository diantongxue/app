import { LogEntry } from '@/components/LogViewer';

class Logger {
  private logs: LogEntry[] = [];
  private maxLogs: number = 1000;
  private listeners: Set<(logs: LogEntry[]) => void> = new Set();

  // 添加日志
  addLog(level: 'info' | 'warn' | 'error', message: string) {
    const log: LogEntry = {
      timestamp: new Date().toLocaleString('zh-CN', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit',
      }),
      level,
      message,
    };

    this.logs.push(log);

    // 限制日志数量
    if (this.logs.length > this.maxLogs) {
      this.logs.shift();
    }

    // 通知所有监听者
    this.notifyListeners();
  }

  // 获取所有日志
  getLogs(): LogEntry[] {
    return [...this.logs];
  }

  // 清空日志
  clearLogs() {
    this.logs = [];
    this.notifyListeners();
  }

  // 订阅日志变化
  subscribe(listener: (logs: LogEntry[]) => void) {
    this.listeners.add(listener);
    return () => {
      this.listeners.delete(listener);
    };
  }

  // 通知监听者 - 使用setTimeout避免在渲染期间触发状态更新
  private notifyListeners() {
    // 使用setTimeout确保在下一个事件循环中执行，避免在渲染期间触发状态更新
    setTimeout(() => {
      const logs = this.getLogs();
      this.listeners.forEach(listener => listener(logs));
    }, 0);
  }

  // 便捷方法
  info(message: string) {
    this.addLog('info', message);
  }

  warn(message: string) {
    this.addLog('warn', message);
  }

  error(message: string) {
    this.addLog('error', message);
  }
}

// 创建全局日志实例
export const logger = new Logger();

// 创建模块特定的日志实例
export const createModuleLogger = (moduleName: string) => {
  return {
    info: (message: string) => logger.info(`[${moduleName}] ${message}`),
    warn: (message: string) => logger.warn(`[${moduleName}] ${message}`),
    error: (message: string) => logger.error(`[${moduleName}] ${message}`),
  };
};

