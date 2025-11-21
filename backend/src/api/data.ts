import { Router } from 'express';
import { DataService } from '../services/data/data-service';
import { logger } from '../utils/logger';

export default function dataRoutes(dataService: DataService) {
  const router = Router();

  // 获取数据列表
  router.get('/list', (req, res) => {
    try {
      const { deviceId, type, startTime, endTime } = req.query;
      
      const filters: any = {};
      if (deviceId) filters.deviceId = deviceId as string;
      if (type) filters.type = type as string;
      if (startTime) filters.startTime = parseInt(startTime as string);
      if (endTime) filters.endTime = parseInt(endTime as string);

      const data = dataService.getAllData(filters);
      logger.info('获取数据列表', 'API');
      res.json({ success: true, data, total: data.length });
    } catch (error: any) {
      logger.error(`获取数据列表失败: ${error.message}`, 'API');
      res.status(500).json({ success: false, message: error.message });
    }
  });

  // 获取数据详情
  router.get('/:id', (req, res) => {
    try {
      const data = dataService.getData(req.params.id);
      if (data) {
        logger.info(`获取数据详情: ${req.params.id}`, 'API');
        res.json({ success: true, data });
      } else {
        res.status(404).json({ success: false, message: '数据不存在' });
      }
    } catch (error: any) {
      logger.error(`获取数据详情失败: ${error.message}`, 'API');
      res.status(500).json({ success: false, message: error.message });
    }
  });

  // 获取统计数据
  router.get('/statistics/:deviceId?', (req, res) => {
    try {
      const deviceId = req.params.deviceId;
      const stats = dataService.getStatistics(deviceId);
      logger.info(`获取统计数据: ${deviceId || 'all'}`, 'API');
      res.json({ success: true, data: stats });
    } catch (error: any) {
      logger.error(`获取统计数据失败: ${error.message}`, 'API');
      res.status(500).json({ success: false, message: error.message });
    }
  });

  // 删除数据
  router.delete('/:id', (req, res) => {
    try {
      dataService.deleteData(req.params.id);
      logger.info(`删除数据: ${req.params.id}`, 'API');
      res.json({ success: true, message: '数据已删除' });
    } catch (error: any) {
      logger.error(`删除数据失败: ${error.message}`, 'API');
      res.status(500).json({ success: false, message: error.message });
    }
  });

  // 导出数据
  router.get('/export', (req, res) => {
    try {
      const { deviceId, type, startTime, endTime } = req.query;
      
      const filters: any = {};
      if (deviceId) filters.deviceId = deviceId as string;
      if (type) filters.type = type as string;
      if (startTime) filters.startTime = parseInt(startTime as string);
      if (endTime) filters.endTime = parseInt(endTime as string);

      const data = dataService.getAllData(filters);
      
      // 转换为CSV格式
      const csvHeaders = ['ID', '设备ID', '数据类型', '时间戳', '创建时间', '内容'];
      const csvRows = data.map(item => [
        item.id,
        item.deviceId,
        item.type,
        item.timestamp,
        item.createdAt,
        JSON.stringify(item.content),
      ]);

      const csvContent = [
        csvHeaders.join(','),
        ...csvRows.map(row => row.map(cell => `"${cell}"`).join(',')),
      ].join('\n');

      res.setHeader('Content-Type', 'text/csv;charset=utf-8');
      res.setHeader('Content-Disposition', `attachment; filename="data_export_${Date.now()}.csv"`);
      res.send('\ufeff' + csvContent); // 添加BOM以支持Excel中文显示
      
      logger.info('导出数据', 'API');
    } catch (error: any) {
      logger.error(`导出数据失败: ${error.message}`, 'API');
      res.status(500).json({ success: false, message: error.message });
    }
  });

  return router;
}

