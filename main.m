% 清空窗口
clear;
clf;
clc;
% 环境准备
axis equal;% 校齐坐标轴
xlabel('x');% 标识x轴
ylabel('y');% 标识y轴
zlabel('z');% 标识z轴

% 参数准备
fineness=1;% 渲染精细度，分辨率
flower_position=[0,0,0];% 花朵位置,以花托为准
flower_size=1;% 放大倍数
petal_number=10;% 花瓣数量
calyx_number=4;% 花萼数量

% 生成对象
rose=Rose(fineness,flower_position,flower_size,petal_number,calyx_number);
rose.Render();% 渲染图形
