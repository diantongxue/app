import { Router } from 'express';
import { DeviceService } from '../services/device/device-service';
import { WebSocketHandler } from '../services/websocket/handler';
import { OperationService } from '../services/operation/operation-service';
import { DeviceConnectionManager } from '../services/adb/device-connection';
import { logger } from '../utils/logger';

export default function deviceRoutes(
  deviceService: DeviceService,
  wsHandler: WebSocketHandler,
  operationService?: OperationService,
  deviceConnectionManager?: DeviceConnectionManager
) {
  const router = Router();

  // 获取设备列表
  router.get('/list', (req, res) => {
    try {
      const devices = deviceService.getDevices();
      logger.info('获取设备列表', 'API');
      res.json({ success: true, data: devices });
    } catch (error: any) {
      logger.error(`获取设备列表失败: ${error.message}`, 'API');
      res.status(500).json({ success: false, message: error.message });
    }
  });

  // 获取设备详情
  router.get('/:id', (req, res) => {
    try {
      const device = deviceService.getDevice(req.params.id);
      if (device) {
        logger.info(`获取设备详情: ${req.params.id}`, 'API');
        res.json({ success: true, data: device });
      } else {
        res.status(404).json({ success: false, message: '设备不存在' });
      }
    } catch (error: any) {
      logger.error(`获取设备详情失败: ${error.message}`, 'API');
      res.status(500).json({ success: false, message: error.message });
    }
  });

  // 发送控制指令
  router.post('/:id/command', (req, res) => {
    try {
      const { id } = req.params;
      const command = req.body;
      
      const success = wsHandler.sendCommandToDevice(id, command);
      if (success) {
        logger.info(`发送指令给设备: ${id}`, 'API');
        
        // 记录操作日志
        if (operationService) {
          operationService.logOperation(id, command.type || 'unknown', command);
        }
        
        res.json({ success: true, message: '指令已发送' });
      } else {
        res.status(400).json({ success: false, message: '设备未连接' });
      }
    } catch (error: any) {
      logger.error(`发送指令失败: ${error.message}`, 'API');
      res.status(500).json({ success: false, message: error.message });
    }
  });

  // 连接设备（网络ADB）
  router.post('/:id/connect', async (req, res) => {
    try {
      const { id } = req.params;
      const { ip, port } = req.body;
      
      if (!deviceConnectionManager) {
        return res.status(503).json({ success: false, message: '设备连接管理器未初始化' });
      }

      if (ip && port) {
        const success = await deviceConnectionManager.connectDevice(ip, port);
        if (success) {
          logger.info(`连接设备成功: ${ip}:${port}`, 'API');
          res.json({ success: true, message: '设备连接成功' });
        } else {
          res.status(400).json({ success: false, message: '设备连接失败' });
        }
      } else {
        res.status(400).json({ success: false, message: '缺少ip和port参数' });
      }
    } catch (error: any) {
      logger.error(`连接设备失败: ${error.message}`, 'API');
      res.status(500).json({ success: false, message: error.message });
    }
  });

  // 断开设备连接
  router.post('/:id/disconnect', async (req, res) => {
    try {
      const { id } = req.params;
      
      if (!deviceConnectionManager) {
        return res.status(503).json({ success: false, message: '设备连接管理器未初始化' });
      }

      const success = await deviceConnectionManager.disconnectDevice(id);
      if (success) {
        logger.info(`断开设备连接: ${id}`, 'API');
        res.json({ success: true, message: '设备已断开' });
      } else {
        res.status(400).json({ success: false, message: '断开连接失败' });
      }
    } catch (error: any) {
      logger.error(`断开设备连接失败: ${error.message}`, 'API');
      res.status(500).json({ success: false, message: error.message });
    }
  });

  // 开启网络ADB模式
  router.post('/:id/enable-network-adb', async (req, res) => {
    try {
      const { id } = req.params;
      const { port } = req.body;
      
      if (!deviceConnectionManager) {
        return res.status(503).json({ success: false, message: '设备连接管理器未初始化' });
      }

      const success = await deviceConnectionManager.enableNetworkADB(id, port || 5555);
      if (success) {
        logger.info(`开启网络ADB模式: ${id}`, 'API');
        res.json({ success: true, message: '网络ADB模式已开启' });
      } else {
        res.status(400).json({ success: false, message: '开启网络ADB模式失败' });
      }
    } catch (error: any) {
      logger.error(`开启网络ADB模式失败: ${error.message}`, 'API');
      res.status(500).json({ success: false, message: error.message });
    }
  });

  // 扫描设备
  router.post('/scan', async (req, res) => {
    try {
      if (!deviceConnectionManager) {
        return res.status(503).json({ success: false, message: '设备连接管理器未初始化' });
      }

      await deviceConnectionManager.scanDevices();
      const devices = deviceService.getDevices();
      logger.info('手动扫描设备', 'API');
      res.json({ success: true, data: devices, message: '设备扫描完成' });
    } catch (error: any) {
      logger.error(`扫描设备失败: ${error.message}`, 'API');
      res.status(500).json({ success: false, message: error.message });
    }
  });

  return router;
}

