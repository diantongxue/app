import { Router } from 'express';
import { OperationService } from '../services/operation/operation-service';
import { logger } from '../utils/logger';

export default function operationRoutes(operationService: OperationService) {
  const router = Router();

  // 获取操作日志列表
  router.get('/list', (req, res) => {
    try {
      const { deviceId, operation, startTime, endTime } = req.query;
      
      const filters: any = {};
      if (deviceId) filters.deviceId = deviceId as string;
      if (operation) filters.operation = operation as string;
      if (startTime) filters.startTime = parseInt(startTime as string);
      if (endTime) filters.endTime = parseInt(endTime as string);

      const logs = operationService.getAllOperations(filters);
      logger.info('获取操作日志列表', 'API');
      res.json({ success: true, data: logs, total: logs.length });
    } catch (error: any) {
      logger.error(`获取操作日志列表失败: ${error.message}`, 'API');
      res.status(500).json({ success: false, message: error.message });
    }
  });

  // 获取设备操作日志
  router.get('/device/:deviceId', (req, res) => {
    try {
      const logs = operationService.getDeviceOperations(req.params.deviceId);
      logger.info(`获取设备操作日志: ${req.params.deviceId}`, 'API');
      res.json({ success: true, data: logs, total: logs.length });
    } catch (error: any) {
      logger.error(`获取设备操作日志失败: ${error.message}`, 'API');
      res.status(500).json({ success: false, message: error.message });
    }
  });

  // 获取操作日志详情
  router.get('/:id', (req, res) => {
    try {
      const log = operationService.getOperationLog(req.params.id);
      if (log) {
        logger.info(`获取操作日志详情: ${req.params.id}`, 'API');
        res.json({ success: true, data: log });
      } else {
        res.status(404).json({ success: false, message: '操作日志不存在' });
      }
    } catch (error: any) {
      logger.error(`获取操作日志详情失败: ${error.message}`, 'API');
      res.status(500).json({ success: false, message: error.message });
    }
  });

  // 删除操作日志
  router.delete('/:id', (req, res) => {
    try {
      operationService.deleteOperation(req.params.id);
      logger.info(`删除操作日志: ${req.params.id}`, 'API');
      res.json({ success: true, message: '操作日志已删除' });
    } catch (error: any) {
      logger.error(`删除操作日志失败: ${error.message}`, 'API');
      res.status(500).json({ success: false, message: error.message });
    }
  });

  return router;
}

