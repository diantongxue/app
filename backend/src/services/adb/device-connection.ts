import { ADBManager, ADBDevice } from './adb-manager';
import { DeviceService } from '../device/device-service';
import { logger } from '../../utils/logger';

export class DeviceConnectionManager {
  private adbManager: ADBManager;
  private deviceService: DeviceService;
  private scanTimer: NodeJS.Timeout | null = null;
  private connectedDevices: Map<string, ADBDevice> = new Map();

  constructor(deviceService: DeviceService) {
    this.adbManager = new ADBManager();
    this.deviceService = deviceService;
  }

  // 初始化
  async initialize() {
    const available = await this.adbManager.checkADBAvailable();
    if (!available) {
      logger.warn('ADB工具不可用，设备连接管理功能受限', 'DeviceConnection');
      return false;
    }

    // 开始定期扫描设备
    this.startDeviceScan();
    logger.info('设备连接管理器已初始化', 'DeviceConnection');
    return true;
  }

  // 开始设备扫描
  startDeviceScan(interval: number = 5000) {
    if (this.scanTimer) {
      clearInterval(this.scanTimer);
    }

    this.scanTimer = setInterval(async () => {
      await this.scanDevices();
    }, interval);

    // 立即扫描一次
    this.scanDevices();
  }

  // 停止设备扫描
  stopDeviceScan() {
    if (this.scanTimer) {
      clearInterval(this.scanTimer);
      this.scanTimer = null;
    }
  }

  // 扫描设备
  async scanDevices() {
    try {
      const adbDevices = await this.adbManager.getDevices();
      
      // 更新已连接的设备
      const currentDeviceIds = new Set(adbDevices.map(d => d.id));
      
      // 移除已断开的设备
      for (const [deviceId] of this.connectedDevices) {
        if (!currentDeviceIds.has(deviceId)) {
          this.connectedDevices.delete(deviceId);
          this.deviceService.updateDeviceStatus(deviceId, 'offline');
          logger.info(`设备已断开: ${deviceId}`, 'DeviceConnection');
        }
      }

      // 添加或更新新设备
      for (const adbDevice of adbDevices) {
        if (adbDevice.type === 'device') {
          const existing = this.connectedDevices.get(adbDevice.id);
          
          if (!existing) {
            // 新设备
            this.connectedDevices.set(adbDevice.id, adbDevice);
            
            // 获取设备详细信息
            const deviceInfo = await this.adbManager.getDeviceInfo(adbDevice.id);
            
            // 注册到设备服务
            this.deviceService.registerDevice(adbDevice.id, {
              name: adbDevice.name,
              model: deviceInfo.model,
              brand: deviceInfo.brand,
              androidVersion: deviceInfo.androidVersion,
              sdkVersion: deviceInfo.sdkVersion,
              connection: adbDevice.connection,
              ip: adbDevice.ip,
            });
            
            logger.info(`发现新设备: ${adbDevice.id} - ${adbDevice.name}`, 'DeviceConnection');
          } else {
            // 更新设备状态
            this.deviceService.updateDeviceStatus(adbDevice.id, 'online');
          }
        }
      }
    } catch (error: any) {
      logger.error(`扫描设备失败: ${error.message}`, 'DeviceConnection');
    }
  }

  // 手动连接设备（网络ADB）
  async connectDevice(ip: string, port: number = 5555): Promise<boolean> {
    const success = await this.adbManager.connectNetwork(ip, port);
    if (success) {
      // 触发设备扫描
      await this.scanDevices();
    }
    return success;
  }

  // 断开设备连接
  async disconnectDevice(deviceId: string): Promise<boolean> {
    const success = await this.adbManager.disconnect(deviceId);
    if (success) {
      this.connectedDevices.delete(deviceId);
      this.deviceService.updateDeviceStatus(deviceId, 'offline');
    }
    return success;
  }

  // 开启网络ADB模式
  async enableNetworkADB(deviceId: string, port: number = 5555): Promise<boolean> {
    return await this.adbManager.enableNetworkADB(deviceId, port);
  }

  // 获取所有已连接的设备
  getConnectedDevices(): ADBDevice[] {
    return Array.from(this.connectedDevices.values());
  }
}

