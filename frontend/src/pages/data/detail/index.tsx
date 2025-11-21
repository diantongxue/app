import React, { useState, useEffect } from 'react';
import { PageContainer } from '@ant-design/pro-components';
import { Card, Descriptions, Tag, Spin, message } from 'antd';
import { useParams } from 'react-router-dom';
import LogViewer, { LogEntry } from '@/components/LogViewer';
import { logger } from '@/utils/logger';
import { dataApi } from '@/services/api';

const DataDetail: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const [logs, setLogs] = useState<LogEntry[]>([]);
  const [loading, setLoading] = useState(true);
  const [data, setData] = useState<any>(null);

  useEffect(() => {
    const unsubscribe = logger.subscribe((newLogs) => {
      setLogs(newLogs);
    });

    const fetchData = async () => {
      if (!id) return;
      
      try {
        logger.info(`查看数据详情，ID: ${id}`);
        setLoading(true);
        const response = await dataApi.getData(id);
        setData(response.data);
        logger.info('数据详情加载成功');
      } catch (error: any) {
        logger.error(`获取数据详情失败: ${error.message}`);
        message.error('获取数据详情失败');
      } finally {
        setLoading(false);
      }
    };

    fetchData();

    return () => {
      unsubscribe();
    };
  }, [id]);

  if (loading) {
    return (
      <PageContainer title="数据详情">
        <Spin size="large" style={{ display: 'block', textAlign: 'center', padding: '50px' }} />
      </PageContainer>
    );
  }

  if (!data) {
    return (
      <PageContainer title="数据详情">
        <Card>数据不存在</Card>
      </PageContainer>
    );
  }

  return (
    <PageContainer title="数据详情">
      <Card>
        <Descriptions title="基本信息" bordered column={2}>
          <Descriptions.Item label="数据ID">{data.id}</Descriptions.Item>
          <Descriptions.Item label="设备ID">{data.deviceId}</Descriptions.Item>
          <Descriptions.Item label="数据类型">
            <Tag color="blue">{data.type}</Tag>
          </Descriptions.Item>
          <Descriptions.Item label="采集时间">{data.createdAt}</Descriptions.Item>
        </Descriptions>
      </Card>

      <Card title="数据内容" style={{ marginTop: 16 }}>
        <pre style={{ 
          background: '#f5f5f5', 
          padding: '16px', 
          borderRadius: '4px',
          overflow: 'auto',
          maxHeight: '500px',
        }}>
          {JSON.stringify(data.content, null, 2)}
        </pre>
      </Card>
      
      <div style={{ marginTop: 24 }}>
        <LogViewer 
          logs={logs} 
          title="详情日志"
          onClear={() => logger.clearLogs()}
        />
      </div>
    </PageContainer>
  );
};

export default DataDetail;

