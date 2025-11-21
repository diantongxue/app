import React, { useState, useEffect } from 'react';
import { PageContainer, ProTable } from '@ant-design/pro-components';
import { Button, Space, Tag } from 'antd';
import { EyeOutlined, DeleteOutlined } from '@ant-design/icons';
import type { ProColumns } from '@ant-design/pro-components';
import LogViewer, { LogEntry } from '@/components/LogViewer';
import { logger } from '@/utils/logger';
import { dataApi } from '@/services/api';
import { wsService } from '@/services/websocket';

interface DataItem {
  id: string;
  deviceId: string;
  type: string;
  content: any;
  timestamp: number;
  createdAt: string;
}

const DataList: React.FC = () => {
  const [logs, setLogs] = useState<LogEntry[]>([]);

  useEffect(() => {
    const unsubscribe = logger.subscribe((newLogs) => {
      setLogs(newLogs);
    });

    // 连接WebSocket
    if (!wsService.isConnected()) {
      wsService.connect();
    }

    // 监听采集数据
    const unsubscribeData = wsService.on('captured_data', (message: any) => {
      logger.info(`收到采集数据: ${message.data?.type || 'unknown'}`);
    });

    logger.info('数据列表页面加载');
    logger.info('正在获取采集数据...');

    return () => {
      unsubscribe();
      unsubscribeData();
    };
  }, []);

  const columns: ProColumns<DataItem>[] = [
    {
      title: 'ID',
      dataIndex: 'id',
      width: 200,
      ellipsis: true,
    },
    {
      title: '设备ID',
      dataIndex: 'deviceId',
      width: 150,
    },
    {
      title: '数据类型',
      dataIndex: 'type',
      width: 150,
      render: (_: any, record: DataItem) => <Tag color="blue">{record.type}</Tag>,
    },
    {
      title: '采集时间',
      dataIndex: 'createdAt',
      width: 180,
      valueType: 'dateTime',
    },
    {
      title: '操作',
      key: 'action',
      width: 150,
      render: (_, record) => (
        <Space>
          <Button
            type="link"
            icon={<EyeOutlined />}
            onClick={() => {
              window.location.href = `/data/detail/${record.id}`;
            }}
          >
            查看
          </Button>
          <Button
            type="link"
            danger
            icon={<DeleteOutlined />}
            onClick={async () => {
              try {
                await dataApi.deleteData(record.id);
                logger.info(`删除数据: ${record.id}`);
                window.location.reload();
              } catch (error: any) {
                logger.error(`删除数据失败: ${error.message}`);
              }
            }}
          >
            删除
          </Button>
        </Space>
      ),
    },
  ];

  return (
    <PageContainer>
      <ProTable<DataItem>
        columns={columns}
        request={async (params) => {
          try {
            logger.info('请求数据列表');
            const response = await dataApi.getDataList({
              deviceId: params.deviceId as string,
              type: params.type as string,
            });
            return {
              data: response.data || [],
              success: true,
              total: response.total || 0,
            };
          } catch (error: any) {
            logger.error(`获取数据列表失败: ${error.message}`);
            return {
              data: [],
              success: false,
              total: 0,
            };
          }
        }}
        rowKey="id"
        search={{
          labelWidth: 'auto',
        }}
        toolBarRender={() => [
          <Button
            key="export"
            onClick={async () => {
              try {
                await dataApi.exportData();
                logger.info('数据导出成功');
              } catch (error: any) {
                logger.error(`数据导出失败: ${error.message}`);
              }
            }}
          >
            导出CSV
          </Button>,
          <Button
            key="refresh"
            onClick={() => {
              logger.info('刷新数据列表');
              window.location.reload();
            }}
          >
            刷新
          </Button>,
        ]}
      />
      
      <div style={{ marginTop: 24 }}>
        <LogViewer 
          logs={logs} 
          title="数据采集日志"
          onClear={() => logger.clearLogs()}
        />
      </div>
    </PageContainer>
  );
};

export default DataList;

