import React, { useState, useEffect } from 'react';
import { PageContainer, ProCard } from '@ant-design/pro-components';
import { Row, Col, Select, Spin, Tabs } from 'antd';
import ReactECharts from 'echarts-for-react';
import LogViewer, { LogEntry } from '@/components/LogViewer';
import { logger } from '@/utils/logger';
import { dataApi, deviceApi } from '@/services/api';


const DataVisualization: React.FC = () => {
  const [logs, setLogs] = useState<LogEntry[]>([]);
  const [loading, setLoading] = useState(false);
  const [statistics, setStatistics] = useState<any>(null);
  const [deviceId, setDeviceId] = useState<string | undefined>(undefined);
  const [devices, setDevices] = useState<any[]>([]);

  useEffect(() => {
    const unsubscribe = logger.subscribe((newLogs) => {
      setLogs(newLogs);
    });

    logger.info('数据可视化页面加载');
    loadDevices();
    loadStatistics();

    return () => {
      unsubscribe();
    };
  }, []);

  useEffect(() => {
    loadStatistics();
  }, [deviceId]);

  const loadDevices = async () => {
    try {
      const response = await deviceApi.getDeviceList();
      setDevices(response.data || []);
    } catch (error: any) {
      logger.error(`获取设备列表失败: ${error.message}`);
    }
  };

  const loadStatistics = async () => {
    try {
      setLoading(true);
      logger.info('正在加载统计数据...');
      const response = await dataApi.getStatistics(deviceId);
      setStatistics(response.data);
      logger.info('统计数据加载成功');
    } catch (error: any) {
      logger.error(`加载统计数据失败: ${error.message}`);
    } finally {
      setLoading(false);
    }
  };

  // 数据类型分布饼图
  const getTypeDistributionChart = () => {
    if (!statistics?.byType) return null;

    const data = Object.entries(statistics.byType).map(([name, value]) => ({
      name,
      value,
    }));

    return {
      title: {
        text: '数据类型分布',
        left: 'center',
      },
      tooltip: {
        trigger: 'item',
      },
      series: [
        {
          type: 'pie',
          radius: '50%',
          data,
          emphasis: {
            itemStyle: {
              shadowBlur: 10,
              shadowOffsetX: 0,
              shadowColor: 'rgba(0, 0, 0, 0.5)',
            },
          },
        },
      ],
    };
  };

  // 时间趋势折线图
  const getTimeTrendChart = () => {
    if (!statistics?.byDate) return null;

    const dates = Object.keys(statistics.byDate).sort();
    const values = dates.map(date => statistics.byDate[date]);

    return {
      title: {
        text: '数据采集趋势',
        left: 'center',
      },
      tooltip: {
        trigger: 'axis',
      },
      xAxis: {
        type: 'category',
        data: dates,
      },
      yAxis: {
        type: 'value',
      },
      series: [
        {
          data: values,
          type: 'line',
          smooth: true,
          areaStyle: {},
        },
      ],
    };
  };

  // 数据类型柱状图
  const getTypeBarChart = () => {
    if (!statistics?.byType) return null;

    const types = Object.keys(statistics.byType);
    const values = types.map(type => statistics.byType[type]);

    return {
      title: {
        text: '数据类型对比',
        left: 'center',
      },
      tooltip: {
        trigger: 'axis',
        axisPointer: {
          type: 'shadow',
        },
      },
      xAxis: {
        type: 'category',
        data: types,
        axisLabel: {
          rotate: 45,
        },
      },
      yAxis: {
        type: 'value',
      },
      series: [
        {
          data: values,
          type: 'bar',
          itemStyle: {
            color: '#1890ff',
          },
        },
      ],
    };
  };

  // 热力图（按小时）
  const getHeatmapChart = () => {
    if (!statistics?.hourlyData) return null;

    const hours = statistics.hourlyData.map((item: any) => item.hour);
    const counts = statistics.hourlyData.map((item: any) => item.count);
    const maxCount = Math.max(...counts, 1);

    return {
      title: {
        text: '数据采集热力图（24小时）',
        left: 'center',
      },
      tooltip: {
        position: 'top',
      },
      xAxis: {
        type: 'category',
        data: hours,
        splitArea: {
          show: true,
        },
      },
      yAxis: {
        type: 'category',
        data: ['数据量'],
        splitArea: {
          show: true,
        },
      },
      visualMap: {
        min: 0,
        max: maxCount,
        calculable: true,
        orient: 'horizontal',
        left: 'center',
        bottom: '15%',
        inRange: {
          color: ['#50a3ba', '#eac736', '#d94e5d'],
        },
      },
      series: [
        {
          name: '数据量',
          type: 'heatmap',
          data: counts.map((count: number, index: number) => [index, 0, count]),
          label: {
            show: true,
              },
          emphasis: {
            itemStyle: {
              shadowBlur: 10,
              shadowColor: 'rgba(0, 0, 0, 0.5)',
            },
          },
        },
      ],
    };
  };

  // 设备数据对比柱状图
  const getDeviceComparisonChart = () => {
    if (!statistics?.byDevice) return null;

    const deviceIds = Object.keys(statistics.byDevice);
    const values = deviceIds.map(id => statistics.byDevice[id]);
    const deviceNames = deviceIds.map(id => {
      const device = devices.find(d => d.id === id);
      return device ? device.name : id;
    });

    return {
      title: {
        text: '设备数据对比',
        left: 'center',
      },
      tooltip: {
        trigger: 'axis',
        axisPointer: {
          type: 'shadow',
        },
      },
      legend: {
        data: ['数据量'],
      },
      xAxis: {
        type: 'category',
        data: deviceNames,
      },
      yAxis: {
        type: 'value',
      },
      series: [
        {
          name: '数据量',
          type: 'bar',
          data: values,
          itemStyle: {
            color: function(params: any) {
              const colors = ['#5470c6', '#91cc75', '#fac858', '#ee6666', '#73c0de'];
              return colors[params.dataIndex % colors.length];
            },
          },
        },
      ],
    };
  };

  // 散点图（时间 vs 数据量）
  const getScatterChart = () => {
    if (!statistics?.byDate) return null;

    const dates = Object.keys(statistics.byDate).sort();
    const data = dates.map((date, index) => [index, statistics.byDate[date]]);

    return {
      title: {
        text: '数据分布散点图',
        left: 'center',
      },
      tooltip: {
        trigger: 'item',
        formatter: (params: any) => {
          const date = dates[params.value[0]];
          return `日期: ${date}<br/>数据量: ${params.value[1]}`;
        },
      },
      xAxis: {
        type: 'value',
        name: '时间序列',
      },
      yAxis: {
        type: 'value',
        name: '数据量',
      },
      series: [
        {
          type: 'scatter',
          data: data,
          symbolSize: (data: number[]) => Math.sqrt(data[1]) * 2,
          itemStyle: {
            color: '#1890ff',
            opacity: 0.6,
          },
        },
      ],
    };
  };

  // 统计卡片数据
  const getStatCards = () => {
    if (!statistics) return [];

    return [
      {
        title: '总数据量',
        value: statistics.total || 0,
        color: '#1890ff',
      },
      {
        title: '数据类型数',
        value: Object.keys(statistics.byType || {}).length,
        color: '#52c41a',
      },
      {
        title: '采集天数',
        value: Object.keys(statistics.byDate || {}).length,
        color: '#faad14',
      },
    ];
  };

  return (
    <PageContainer
      title="数据可视化"
      extra={
        <Select
          placeholder="选择设备"
          style={{ width: 200 }}
          allowClear
          value={deviceId}
          onChange={(value) => {
            setDeviceId(value);
          }}
        >
          {devices.map(device => (
            <Select.Option key={device.id} value={device.id}>
              {device.name}
            </Select.Option>
          ))}
        </Select>
      }
    >
      <Spin spinning={loading}>
        {/* 统计卡片 */}
        <Row gutter={16} style={{ marginBottom: 16 }}>
          {getStatCards().map((card, index) => (
            <Col span={8} key={index}>
              <ProCard>
                <div style={{ textAlign: 'center' }}>
                  <div style={{ fontSize: '24px', fontWeight: 'bold', color: card.color }}>
                    {card.value}
                  </div>
                  <div style={{ marginTop: 8, color: '#666' }}>{card.title}</div>
                </div>
              </ProCard>
            </Col>
          ))}
        </Row>

        {/* 图表 */}
        <Tabs
          defaultActiveKey="1"
          items={[
            {
              key: '1',
              label: '基础图表',
              children: (
                <Row gutter={16}>
                  <Col span={12}>
                    <ProCard title="数据类型分布">
                      {statistics?.byType ? (
                        <ReactECharts
                          option={getTypeDistributionChart()}
                          style={{ height: '400px' }}
                        />
                      ) : (
                        <div style={{ textAlign: 'center', padding: '50px' }}>暂无数据</div>
                      )}
                    </ProCard>
                  </Col>
                  <Col span={12}>
                    <ProCard title="数据采集趋势">
                      {statistics?.byDate ? (
                        <ReactECharts
                          option={getTimeTrendChart()}
                          style={{ height: '400px' }}
                        />
                      ) : (
                        <div style={{ textAlign: 'center', padding: '50px' }}>暂无数据</div>
                      )}
                    </ProCard>
                  </Col>
                </Row>
              ),
            },
            {
              key: '2',
              label: '对比分析',
              children: (
                <Row gutter={16}>
                  <Col span={12}>
                    <ProCard title="数据类型对比">
                      {statistics?.byType ? (
                        <ReactECharts
                          option={getTypeBarChart()}
                          style={{ height: '400px' }}
                        />
                      ) : (
                        <div style={{ textAlign: 'center', padding: '50px' }}>暂无数据</div>
                      )}
                    </ProCard>
                  </Col>
                  <Col span={12}>
                    <ProCard title="设备数据对比">
                      {statistics?.byDevice && Object.keys(statistics.byDevice).length > 0 ? (
                        <ReactECharts
                          option={getDeviceComparisonChart()}
                          style={{ height: '400px' }}
                        />
                      ) : (
                        <div style={{ textAlign: 'center', padding: '50px' }}>暂无数据</div>
                      )}
                    </ProCard>
                  </Col>
                </Row>
              ),
            },
            {
              key: '3',
              label: '高级分析',
              children: (
                <Row gutter={16}>
                  <Col span={12}>
                    <ProCard title="24小时热力图">
                      {statistics?.hourlyData ? (
                        <ReactECharts
                          option={getHeatmapChart()}
                          style={{ height: '400px' }}
                        />
                      ) : (
                        <div style={{ textAlign: 'center', padding: '50px' }}>暂无数据</div>
                      )}
                    </ProCard>
                  </Col>
                  <Col span={12}>
                    <ProCard title="数据分布散点图">
                      {statistics?.byDate ? (
                        <ReactECharts
                          option={getScatterChart()}
                          style={{ height: '400px' }}
                        />
                      ) : (
                        <div style={{ textAlign: 'center', padding: '50px' }}>暂无数据</div>
                      )}
                    </ProCard>
                  </Col>
                </Row>
              ),
            },
          ]}
        />
      </Spin>

      <div style={{ marginTop: 24 }}>
        <LogViewer 
          logs={logs} 
          title="可视化日志"
          onClear={() => logger.clearLogs()}
        />
      </div>
    </PageContainer>
  );
};

export default DataVisualization;
