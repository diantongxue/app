import { logger } from '@/utils/logger';

// 使用fetch替代@umijs/max的request
const request = async (url: string, options?: RequestInit) => {
  const response = await fetch(url, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...options?.headers,
    },
  });
  
  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }
  
  return await response.json();
};

const API_BASE = 'http://localhost:3001/api';

// 设备管理API
export const deviceApi = {
  // 获取设备列表
  getDeviceList: async () => {
    try {
      logger.info('请求设备列表');
      const response = await request(`${API_BASE}/device/list`, {
        method: 'GET',
      });
      return response;
    } catch (error: any) {
      logger.error(`获取设备列表失败: ${error.message}`);
      throw error;
    }
  },

  // 获取设备详情
  getDevice: async (deviceId: string) => {
    try {
      logger.info(`请求设备详情: ${deviceId}`);
      const response = await request(`${API_BASE}/device/${deviceId}`, {
        method: 'GET',
      });
      return response;
    } catch (error: any) {
      logger.error(`获取设备详情失败: ${error.message}`);
      throw error;
    }
  },

  // 发送控制指令
  sendCommand: async (deviceId: string, command: any) => {
    try {
      logger.info(`发送指令给设备: ${deviceId}`);
      const response = await request(`${API_BASE}/device/${deviceId}/command`, {
        method: 'POST',
        body: JSON.stringify(command),
      });
      return response;
    } catch (error: any) {
      logger.error(`发送指令失败: ${error.message}`);
      throw error;
    }
  },
};

// 数据管理API
export const dataApi = {
  // 获取数据列表
  getDataList: async (params?: {
    deviceId?: string;
    type?: string;
    startTime?: number;
    endTime?: number;
  }) => {
    try {
      logger.info('请求数据列表');
      const queryString = params
        ? '?' + new URLSearchParams(params as any).toString()
        : '';
      const response = await request(`${API_BASE}/data/list${queryString}`, {
        method: 'GET',
      });
      return response;
    } catch (error: any) {
      logger.error(`获取数据列表失败: ${error.message}`);
      throw error;
    }
  },

  // 获取数据详情
  getData: async (dataId: string) => {
    try {
      logger.info(`请求数据详情: ${dataId}`);
      const response = await request(`${API_BASE}/data/${dataId}`, {
        method: 'GET',
      });
      return response;
    } catch (error: any) {
      logger.error(`获取数据详情失败: ${error.message}`);
      throw error;
    }
  },

  // 获取统计数据
  getStatistics: async (deviceId?: string) => {
    try {
      logger.info(`请求统计数据: ${deviceId || 'all'}`);
      const url = deviceId
        ? `${API_BASE}/data/statistics/${deviceId}`
        : `${API_BASE}/data/statistics`;
      const response = await request(url, {
        method: 'GET',
      });
      return response;
    } catch (error: any) {
      logger.error(`获取统计数据失败: ${error.message}`);
      throw error;
    }
  },

  // 删除数据
  deleteData: async (dataId: string) => {
    try {
      logger.info(`删除数据: ${dataId}`);
      const response = await request(`${API_BASE}/data/${dataId}`, {
        method: 'DELETE',
      });
      return response;
    } catch (error: any) {
      logger.error(`删除数据失败: ${error.message}`);
      throw error;
    }
  },

  // 导出数据
  exportData: async (params?: {
    deviceId?: string;
    type?: string;
    startTime?: number;
    endTime?: number;
  }) => {
    try {
      logger.info('导出数据');
      const queryString = params
        ? '?' + new URLSearchParams(params as any).toString()
        : '';
      const response = await fetch(`${API_BASE}/data/export${queryString}`);
      const blob = await response.blob();
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `data_export_${Date.now()}.csv`;
      document.body.appendChild(a);
      a.click();
      window.URL.revokeObjectURL(url);
      document.body.removeChild(a);
      logger.info('数据导出成功');
    } catch (error: any) {
      logger.error(`导出数据失败: ${error.message}`);
      throw error;
    }
  },
};

// 操作日志API
export const operationApi = {
  // 获取操作日志列表
  getOperationList: async (params?: {
    deviceId?: string;
    operation?: string;
    startTime?: number;
    endTime?: number;
  }) => {
    try {
      logger.info('请求操作日志列表');
      const queryString = params
        ? '?' + new URLSearchParams(params as any).toString()
        : '';
      const response = await request(`${API_BASE}/operation/list${queryString}`, {
        method: 'GET',
      });
      return response;
    } catch (error: any) {
      logger.error(`获取操作日志列表失败: ${error.message}`);
      throw error;
    }
  },

  // 获取设备操作日志
  getDeviceOperations: async (deviceId: string) => {
    try {
      logger.info(`请求设备操作日志: ${deviceId}`);
      const response = await request(`${API_BASE}/operation/device/${deviceId}`, {
        method: 'GET',
      });
      return response;
    } catch (error: any) {
      logger.error(`获取设备操作日志失败: ${error.message}`);
      throw error;
    }
  },
};

