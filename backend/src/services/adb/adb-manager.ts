import { exec } from 'child_process';
import { promisify } from 'util';
import { logger } from '../../utils/logger';

const execAsync = promisify(exec);

export interface ADBDevice {
  id: string;
  name: string;
  type: 'device' | 'offline' | 'unauthorized';
  connection: 'usb' | 'network';
  ip?: string;
}

export class ADBManager {
  // 检查ADB是否可用
  async checkADBAvailable(): Promise<boolean> {
    try {
      await execAsync('adb version');
      logger.info('ADB工具可用', 'ADBManager');
      return true;
    } catch (error) {
      logger.error('ADB工具不可用，请确保已安装Android SDK Platform Tools', 'ADBManager');
      return false;
    }
  }

  // 获取所有连接的设备
  async getDevices(): Promise<ADBDevice[]> {
    try {
      const { stdout } = await execAsync('adb devices -l');
      const lines = stdout.split('\n').filter(line => line.trim() && !line.includes('List of devices'));
      
      const devices: ADBDevice[] = [];
      
      for (const line of lines) {
        const parts = line.trim().split(/\s+/);
        if (parts.length >= 2) {
          const id = parts[0];
          const type = parts[1] as 'device' | 'offline' | 'unauthorized';
          
          // 判断连接类型
          const connection: 'usb' | 'network' = id.includes(':') ? 'network' : 'usb';
          
          // 提取设备名称
          let name = `设备-${id}`;
          const modelMatch = line.match(/model:(\S+)/);
          if (modelMatch) {
            name = modelMatch[1];
          }
          
          devices.push({
            id,
            name,
            type,
            connection,
            ip: connection === 'network' ? id.split(':')[0] : undefined,
          });
        }
      }
      
      logger.info(`发现 ${devices.length} 个设备`, 'ADBManager');
      return devices;
    } catch (error: any) {
      logger.error(`获取设备列表失败: ${error.message}`, 'ADBManager');
      return [];
    }
  }

  // 通过USB连接设备
  async connectUSB(deviceId: string): Promise<boolean> {
    try {
      logger.info(`通过USB连接设备: ${deviceId}`, 'ADBManager');
      // USB连接通常已经自动连接，这里主要是验证
      const devices = await this.getDevices();
      const device = devices.find(d => d.id === deviceId && d.type === 'device');
      return !!device;
    } catch (error: any) {
      logger.error(`USB连接失败: ${error.message}`, 'ADBManager');
      return false;
    }
  }

  // 通过网络ADB连接设备
  async connectNetwork(ip: string, port: number = 5555): Promise<boolean> {
    try {
      logger.info(`通过网络ADB连接设备: ${ip}:${port}`, 'ADBManager');
      await execAsync(`adb connect ${ip}:${port}`);
      
      // 等待连接建立
      await new Promise(resolve => setTimeout(resolve, 2000));
      
      // 验证连接
      const devices = await this.getDevices();
      const device = devices.find(d => d.id === `${ip}:${port}` && d.type === 'device');
      
      if (device) {
        logger.info(`网络ADB连接成功: ${ip}:${port}`, 'ADBManager');
        return true;
      } else {
        logger.warn(`网络ADB连接失败: ${ip}:${port}`, 'ADBManager');
        return false;
      }
    } catch (error: any) {
      logger.error(`网络ADB连接失败: ${error.message}`, 'ADBManager');
      return false;
    }
  }

  // 断开设备连接
  async disconnect(deviceId: string): Promise<boolean> {
    try {
      logger.info(`断开设备连接: ${deviceId}`, 'ADBManager');
      await execAsync(`adb disconnect ${deviceId}`);
      return true;
    } catch (error: any) {
      logger.error(`断开连接失败: ${error.message}`, 'ADBManager');
      return false;
    }
  }

  // 开启网络ADB模式（需要先USB连接）
  async enableNetworkADB(deviceId: string, port: number = 5555): Promise<boolean> {
    try {
      logger.info(`为设备 ${deviceId} 开启网络ADB模式`, 'ADBManager');
      await execAsync(`adb -s ${deviceId} tcpip ${port}`);
      logger.info(`网络ADB模式已开启，端口: ${port}`, 'ADBManager');
      return true;
    } catch (error: any) {
      logger.error(`开启网络ADB模式失败: ${error.message}`, 'ADBManager');
      return false;
    }
  }

  // 执行ADB命令
  async executeCommand(deviceId: string, command: string): Promise<string> {
    try {
      const { stdout } = await execAsync(`adb -s ${deviceId} ${command}`);
      return stdout;
    } catch (error: any) {
      logger.error(`执行ADB命令失败: ${error.message}`, 'ADBManager');
      throw error;
    }
  }

  // 获取设备信息
  async getDeviceInfo(deviceId: string): Promise<any> {
    try {
      const [model, brand, androidVersion, sdkVersion] = await Promise.all([
        this.executeCommand(deviceId, 'shell getprop ro.product.model').catch(() => ''),
        this.executeCommand(deviceId, 'shell getprop ro.product.brand').catch(() => ''),
        this.executeCommand(deviceId, 'shell getprop ro.build.version.release').catch(() => ''),
        this.executeCommand(deviceId, 'shell getprop ro.build.version.sdk').catch(() => ''),
      ]);

      return {
        model: model.trim(),
        brand: brand.trim(),
        androidVersion: androidVersion.trim(),
        sdkVersion: sdkVersion.trim(),
      };
    } catch (error: any) {
      logger.error(`获取设备信息失败: ${error.message}`, 'ADBManager');
      return {};
    }
  }

  // 定期扫描设备
  startDeviceScan(interval: number = 5000, callback?: (devices: ADBDevice[]) => void) {
    const scan = async () => {
      const devices = await this.getDevices();
      if (callback) {
        callback(devices);
      }
    };

    // 立即扫描一次
    scan();

    // 定期扫描
    const timer = setInterval(scan, interval);
    
    return () => {
      clearInterval(timer);
    };
  }
}

