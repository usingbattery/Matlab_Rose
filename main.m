% 清空窗口
clear;
clf;
clc;
% 环境准备
xlabel('x');% 标识x轴
axis equal;% 校齐坐标轴
ylabel('y');% 标识y轴
zlabel('z');% 标识z轴

% 参数准备
fineness=1;% 渲染精细度，分辨率
flower_position=[0,0,0];% 位置，花萼根部坐标
flower_size=1;% 放大倍数
petal_number=10;% 花瓣数量
calyx_number=4;% 花萼数量

% 生成对象
rose=Rose(fineness,flower_position,flower_size,petal_number,calyx_number);
rose.Render();% 渲染图形
% 对象修改
rose.petal_baseColor=[0.35,0,0.5,0.36];
rose.petal_line_color_=[245,215,0]./255;
figure(2);
clf;
axis equal;% 校齐坐标轴
rose.Render();
