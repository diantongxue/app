import { logger } from '../../utils/logger';

export interface OperationLog {
  id: string;
  deviceId: string;
  operation: string;
  details: any;
  timestamp: number;
  createdAt: string;
}

export class OperationService {
  private logs: Map<string, OperationLog> = new Map();
  private logIndex: number = 0;

  // 记录操作
  logOperation(deviceId: string, operation: string, details: any): OperationLog {
    const id = `op_${++this.logIndex}_${Date.now()}`;
    const log: OperationLog = {
      id,
      deviceId,
      operation,
      details,
      timestamp: Date.now(),
      createdAt: new Date().toISOString(),
    };
    this.logs.set(id, log);
    logger.info(`记录操作: ${operation} - 设备: ${deviceId}`, 'OperationService');
    return log;
  }

  // 获取操作日志
  getOperationLog(id: string): OperationLog | undefined {
    return this.logs.get(id);
  }

  // 获取设备操作日志
  getDeviceOperations(deviceId: string): OperationLog[] {
    return Array.from(this.logs.values())
      .filter(log => log.deviceId === deviceId)
      .sort((a, b) => b.timestamp - a.timestamp);
  }

  // 获取所有操作日志
  getAllOperations(filters?: {
    deviceId?: string;
    operation?: string;
    startTime?: number;
    endTime?: number;
  }): OperationLog[] {
    let result = Array.from(this.logs.values());

    if (filters) {
      if (filters.deviceId) {
        result = result.filter(log => log.deviceId === filters.deviceId);
      }
      if (filters.operation) {
        result = result.filter(log => log.operation === filters.operation);
      }
      if (filters.startTime) {
        result = result.filter(log => log.timestamp >= filters.startTime!);
      }
      if (filters.endTime) {
        result = result.filter(log => log.timestamp <= filters.endTime!);
      }
    }

    return result.sort((a, b) => b.timestamp - a.timestamp);
  }

  // 删除操作日志
  deleteOperation(id: string) {
    this.logs.delete(id);
    logger.info(`删除操作日志: ${id}`, 'OperationService');
  }
}

