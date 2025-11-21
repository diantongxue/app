import { logger } from '../../utils/logger';

export interface Device {
  id: string;
  name: string;
  status: 'online' | 'offline';
  lastOnline?: string;
  info?: any;
}

export class DeviceService {
  private devices: Map<string, Device> = new Map();

  // 注册设备
  registerDevice(deviceId: string, info: any) {
    const device: Device = {
      id: deviceId,
      name: info.name || `设备-${deviceId}`,
      status: 'online',
      lastOnline: new Date().toISOString(),
      info,
    };
    this.devices.set(deviceId, device);
    logger.info(`设备注册: ${deviceId}`, 'DeviceService');
    return device;
  }

  // 更新设备状态
  updateDeviceStatus(deviceId: string, status: 'online' | 'offline') {
    const device = this.devices.get(deviceId);
    if (device) {
      device.status = status;
      device.lastOnline = new Date().toISOString();
      logger.info(`设备状态更新: ${deviceId} - ${status}`, 'DeviceService');
    }
  }

  // 获取设备
  getDevice(deviceId: string): Device | undefined {
    return this.devices.get(deviceId);
  }

  // 获取所有设备
  getDevices(): Device[] {
    return Array.from(this.devices.values());
  }

  // 删除设备
  removeDevice(deviceId: string) {
    this.devices.delete(deviceId);
    logger.info(`设备删除: ${deviceId}`, 'DeviceService');
  }
}

