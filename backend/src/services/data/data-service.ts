import { logger } from '../../utils/logger';

export interface CapturedData {
  id: string;
  deviceId: string;
  type: string;
  content: any;
  timestamp: number;
  createdAt: string;
}

export class DataService {
  private data: Map<string, CapturedData> = new Map();
  private dataIndex: number = 0;

  // 保存采集数据
  saveData(deviceId: string, type: string, content: any): CapturedData {
    const id = `data_${++this.dataIndex}_${Date.now()}`;
    const data: CapturedData = {
      id,
      deviceId,
      type,
      content,
      timestamp: Date.now(),
      createdAt: new Date().toISOString(),
    };
    this.data.set(id, data);
    logger.info(`保存数据: ${id}`, 'DataService');
    return data;
  }

  // 获取数据
  getData(id: string): CapturedData | undefined {
    return this.data.get(id);
  }

  // 获取设备的所有数据
  getDeviceData(deviceId: string): CapturedData[] {
    return Array.from(this.data.values())
      .filter(d => d.deviceId === deviceId)
      .sort((a, b) => b.timestamp - a.timestamp);
  }

  // 获取所有数据
  getAllData(filters?: {
    deviceId?: string;
    type?: string;
    startTime?: number;
    endTime?: number;
  }): CapturedData[] {
    let result = Array.from(this.data.values());

    if (filters) {
      if (filters.deviceId) {
        result = result.filter(d => d.deviceId === filters.deviceId);
      }
      if (filters.type) {
        result = result.filter(d => d.type === filters.type);
      }
      if (filters.startTime) {
        result = result.filter(d => d.timestamp >= filters.startTime!);
      }
      if (filters.endTime) {
        result = result.filter(d => d.timestamp <= filters.endTime!);
      }
    }

    return result.sort((a, b) => b.timestamp - a.timestamp);
  }

  // 删除数据
  deleteData(id: string) {
    this.data.delete(id);
    logger.info(`删除数据: ${id}`, 'DataService');
  }

  // 获取统计数据
  getStatistics(deviceId?: string) {
    const data = deviceId ? this.getDeviceData(deviceId) : this.getAllData();
    
    const stats = {
      total: data.length,
      byType: {} as Record<string, number>,
      byDate: {} as Record<string, number>,
      byHour: {} as Record<string, number>,
      byDevice: {} as Record<string, number>,
      hourlyData: [] as Array<{ hour: string; count: number }>,
    };

    data.forEach(d => {
      // 按类型统计
      stats.byType[d.type] = (stats.byType[d.type] || 0) + 1;
      
      // 按日期统计
      const date = new Date(d.timestamp).toLocaleDateString('zh-CN');
      stats.byDate[date] = (stats.byDate[date] || 0) + 1;
      
      // 按小时统计
      const hour = new Date(d.timestamp).getHours();
      const hourKey = `${hour}:00`;
      stats.byHour[hourKey] = (stats.byHour[hourKey] || 0) + 1;
      
      // 按设备统计
      stats.byDevice[d.deviceId] = (stats.byDevice[d.deviceId] || 0) + 1;
    });

    // 生成小时数据数组（用于热力图）
    for (let h = 0; h < 24; h++) {
      const hourKey = `${h}:00`;
      stats.hourlyData.push({
        hour: hourKey,
        count: stats.byHour[hourKey] || 0,
      });
    }

    return stats;
  }
}

