import { defineConfig } from '@umijs/max';

export default defineConfig({
  mfsu: false, // 暂时禁用MFSU以解决模块加载问题
  routes: [
    {
      path: '/login',
      name: '登录',
      component: './login',
      layout: false,
    },
    {
      path: '/',
      component: './layouts/BasicLayout',
      routes: [
    {
      path: '/device',
      name: '设备管理',
      icon: 'mobile',
      routes: [
        {
          path: '/device/list',
          name: '设备列表',
          component: './device/list',
        },
        {
          path: '/device/control/:id',
          name: '远程控制',
          component: './device/control',
          hideInMenu: true,
        },
      ],
      redirect: '/device/list',
    },
    {
      path: '/data',
      name: '数据采集',
      icon: 'database',
      routes: [
        {
          path: '/data/list',
          name: '数据列表',
          component: './data/list',
        },
        {
          path: '/data/visualization',
          name: '数据可视化',
          component: './data/visualization',
        },
        {
          path: '/data/detail/:id',
          name: '数据详情',
          component: './data/detail',
          hideInMenu: true,
            },
          ],
        },
      ],
    },
  ],
  npmClient: 'npm',
});

