import React, { useState, useEffect } from 'react';
import { Card, Table, Tag, Button, Space } from 'antd';
import { ReloadOutlined } from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import { operationApi } from '@/services/api';
import { logger } from '@/utils/logger';

interface OperationLog {
  id: string;
  deviceId: string;
  operation: string;
  details: any;
  timestamp: number;
  createdAt: string;
}

interface OperationHistoryProps {
  deviceId?: string;
  height?: number;
}

const OperationHistory: React.FC<OperationHistoryProps> = ({ 
  deviceId,
  height = 400 
}) => {
  const [loading, setLoading] = useState(false);
  const [data, setData] = useState<OperationLog[]>([]);

  const loadData = async () => {
    try {
      setLoading(true);
      logger.info('加载操作历史记录');
      const response = deviceId
        ? await operationApi.getDeviceOperations(deviceId)
        : await operationApi.getOperationList();
      setData(response.data || []);
      logger.info('操作历史记录加载成功');
    } catch (error: any) {
      logger.error(`加载操作历史记录失败: ${error.message}`);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadData();
    // 定期刷新
    const interval = setInterval(loadData, 5000);
    return () => clearInterval(interval);
  }, [deviceId]);

  const columns: ColumnsType<OperationLog> = [
    {
      title: '时间',
      dataIndex: 'createdAt',
      key: 'createdAt',
      width: 180,
      render: (text: string) => new Date(text).toLocaleString('zh-CN'),
    },
    {
      title: '设备ID',
      dataIndex: 'deviceId',
      key: 'deviceId',
      width: 150,
    },
    {
      title: '操作类型',
      dataIndex: 'operation',
      key: 'operation',
      width: 150,
      render: (operation: string) => (
        <Tag color="blue">{operation}</Tag>
      ),
    },
    {
      title: '操作详情',
      dataIndex: 'details',
      key: 'details',
      ellipsis: true,
      render: (details: any) => (
        <span title={JSON.stringify(details, null, 2)}>
          {JSON.stringify(details).substring(0, 100)}
          {JSON.stringify(details).length > 100 ? '...' : ''}
        </span>
      ),
    },
  ];

  return (
    <Card
      title={deviceId ? `设备 ${deviceId} 操作历史` : '操作历史记录'}
      extra={
        <Button
          icon={<ReloadOutlined />}
          size="small"
          onClick={loadData}
          loading={loading}
        >
          刷新
        </Button>
      }
    >
      <Table
        columns={columns}
        dataSource={data}
        rowKey="id"
        loading={loading}
        pagination={{
          pageSize: 10,
          showSizeChanger: true,
          showTotal: (total) => `共 ${total} 条记录`,
        }}
        scroll={{ y: height - 100 }}
        size="small"
      />
    </Card>
  );
};

export default OperationHistory;

