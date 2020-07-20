% 清空窗口
clf;
clear;
clc;
% 环境准备
axis equal;
hold on;
xlabel('x');
ylabel('y');
zlabel('z');
% 参数准备
fineness=1; % 渲染精细度
flower_position=[1,2,3]; % 花托位置
flower_size=1; % 放大倍数
petal_number=8; % 花瓣数量
% 画出玫瑰
mylove=Rose(fineness,flower_position,flower_size,petal_number);
mylove.Render();
