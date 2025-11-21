import React, { useState, useEffect, useRef } from 'react';
import { PageContainer, ProTable } from '@ant-design/pro-components';
import { Button, Space } from 'antd';
import { PlayCircleOutlined } from '@ant-design/icons';
import type { ProColumns } from '@ant-design/pro-components';
import { history } from '@umijs/max';
import { isAuthenticated } from '@/utils/auth';
import LogViewer, { LogEntry } from '@/components/LogViewer';
import { logger } from '@/utils/logger';
import { deviceApi } from '@/services/api';
import { wsService } from '@/services/websocket';

interface DeviceItem {
  id: string;
  name: string;
  status: 'online' | 'offline';
  lastOnline?: string;
}

const DeviceList: React.FC = () => {
  const [logs, setLogs] = useState<LogEntry[]>([]);
  const initializedRef = useRef(false);
  const unsubscribeDeviceListRef = useRef<(() => void) | null>(null);
  // 路由保护：检查是否已登录
  useEffect(() => {
    if (!isAuthenticated()) {
      history.push('/login');
    }
  }, []);

  useEffect(() => {
    // 防止重复初始化
    if (initializedRef.current) {
      return;
    }
    initializedRef.current = true;

    // 暂时禁用日志订阅以避免无限循环
    // TODO: 修复日志订阅机制
    // const unsubscribe = logger.subscribe((newLogs) => {
    //   requestAnimationFrame(() => {
    //     setLogs([...newLogs]);
    //   });
    // });

    // 初始化时获取当前日志（不订阅更新）
    const currentLogs = logger.getLogs();
    if (currentLogs.length > 0) {
      setLogs([...currentLogs]);
    }

    // 延迟初始化WebSocket，避免在渲染期间触发
    const initTimer = setTimeout(() => {
    // 连接WebSocket
    if (!wsService.isConnected()) {
      wsService.connect();
    }

    // 监听设备列表更新
      unsubscribeDeviceListRef.current = wsService.on('device_list', () => {
        // 设备列表更新时的处理
        console.log('收到设备列表更新');
    });
    }, 200);

    return () => {
      clearTimeout(initTimer);
      // unsubscribe();
      if (unsubscribeDeviceListRef.current) {
        unsubscribeDeviceListRef.current();
        unsubscribeDeviceListRef.current = null;
      }
      initializedRef.current = false;
    };
  }, []);

  const columns: ProColumns<DeviceItem>[] = [
    {
      title: '设备ID',
      dataIndex: 'id',
      key: 'id',
    },
    {
      title: '设备名称',
      dataIndex: 'name',
      key: 'name',
    },
    {
      title: '状态',
      dataIndex: 'status',
      key: 'status',
      valueEnum: {
        online: { text: '在线', status: 'Success' },
        offline: { text: '离线', status: 'Default' },
      },
    },
    {
      title: '最后在线',
      dataIndex: 'lastOnline',
      key: 'lastOnline',
    },
    {
      title: '操作',
      key: 'action',
      render: (_, record) => (
        <Space>
          <Button
            type="primary"
            icon={<PlayCircleOutlined />}
            onClick={() => {
              logger.info(`准备连接设备: ${record.name}`);
              window.location.href = `/device/control/${record.id}`;
            }}
          >
            远程控制
          </Button>
        </Space>
      ),
    },
  ];

  return (
    <PageContainer title="设备列表">
      <div style={{ padding: 24 }}>
      <ProTable<DeviceItem>
        columns={columns}
        request={async () => {
          try {
            logger.info('请求设备列表数据');
            const response = await deviceApi.getDeviceList();
            return {
              data: response.data || [],
              success: true,
              total: response.data?.length || 0,
            };
          } catch (error: any) {
            logger.error(`获取设备列表失败: ${error.message}`);
            return {
              data: [],
              success: false,
              total: 0,
            };
          }
        }}
        rowKey="id"
        search={false}
        toolBarRender={() => [
          <Button 
            key="refresh" 
            onClick={async () => {
              logger.info('刷新设备列表');
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
          title="设备管理日志"
          onClear={() => logger.clearLogs()}
        />
        </div>
      </div>
    </PageContainer>
  );
};

export default DeviceList;

