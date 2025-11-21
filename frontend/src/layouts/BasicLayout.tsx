import React from 'react';
import { ProLayout } from '@ant-design/pro-components';
import { history, Outlet, useLocation } from '@umijs/max';
import { Button, Dropdown } from 'antd';
import { LogoutOutlined, UserOutlined, MobileOutlined, DatabaseOutlined } from '@ant-design/icons';
import { logout, getUsername } from '@/utils/auth';

const BasicLayout: React.FC = () => {
  const username = getUsername();
  const location = useLocation();

  return (
    <ProLayout
      logo={false}
      title="手机App远程控制系统"
      navTheme="dark"
      primaryColor="#3979FE"
      layout="side"
      contentWidth="Fluid"
      fixedHeader
      fixSiderbar
      menu={{
        locale: false,
      }}
      menuDataRender={() => [
        {
          path: '/device',
          name: '设备管理',
          icon: <MobileOutlined />,
          children: [
            {
              path: '/device/list',
              name: '设备列表',
            },
          ],
        },
        {
          path: '/data',
          name: '数据采集',
          icon: <DatabaseOutlined />,
          children: [
            {
              path: '/data/list',
              name: '数据列表',
            },
            {
              path: '/data/visualization',
              name: '数据可视化',
            },
          ],
        },
      ]}
      location={location}
      rightContentRender={() => (
        <Dropdown
          menu={{
            items: [
              {
                key: 'user',
                label: (
                  <span>
                    <UserOutlined style={{ marginRight: 8 }} />
                    {username || '用户'}
                  </span>
                ),
                disabled: true,
              },
              {
                type: 'divider',
              },
              {
                key: 'logout',
                label: (
                  <span>
                    <LogoutOutlined style={{ marginRight: 8 }} />
                    退出登录
                  </span>
                ),
                onClick: () => {
                  logout();
                  history.push('/login');
                },
              },
            ],
          }}
          placement="bottomRight"
        >
          <Button type="text" style={{ color: '#fff' }}>
            <UserOutlined /> {username || '用户'}
          </Button>
        </Dropdown>
      )}
      onMenuHeaderClick={() => history.push('/device/list')}
      menuItemRender={(item, dom) => (
        <div onClick={() => item.path && history.push(item.path)}>
          {dom}
        </div>
      )}
    >
      <Outlet />
    </ProLayout>
  );
};

export default BasicLayout;
