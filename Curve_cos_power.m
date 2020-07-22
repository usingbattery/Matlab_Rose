function line_y=Curve_cos_power(point,power,x_begin,x_end,pixel_num)

% 曲线生成函数

% 算法:
% 1.以三角函数连接所有点
% 2.以幂函数分段调整曲线

% IO:
% 1.输入多个坐标点
% 2.输出曲线列向量
% 3.输入参数的格式说明：
%     point=[% 极值点
%         x1,x2,...;
%         y1,y2,...]
%     power=[% 凹凸性
%         power12;
%         power23;...]
%     曲线定义域=
%         linspace(x_start,x_end,pixel_num)
% 4.输出参数的格式说明：
%     曲线值域:
%         line_y=zeros(1,pixel_num);

% 数据准备
line_x=linspace(x_begin,x_end,pixel_num);
line_y=zeros(1,pixel_num);

point_num=size(point,2);

point_x=point(1,:);
point_y=point(2,:);

% 针对逐点处理的时间优化
flag_start=1;

% 从左到右逐单调区间处理
for i=1:point_num-1
    % 计算三角函数参数
    omega=pi/(point_x(i+1)-point_x(i));
    phi=point_x(i)*pi/(point_x(i)-point_x(i+1));
    A=0.5*(point_y(i)-point_y(i+1));
    y0=point_y(i)-A;
    
    % 从左到右逐点处理
    for j=flag_start:pixel_num
        % 如果点在定义域内
        if point_x(i)<=line_x(j) && line_x(j)<=point_x(i+1)
            % apply_cos
            if mod(omega*line_x(j)+phi,pi)==pi/2
                % 零点精确值
                line_y(j)=y0;
            else
                line_y(j)=A*cos(omega*line_x(j)+phi)+y0;
            end
        end
        % 定义域外侧点舍弃
        if point_x(i+1)<=line_x(j)
            % 计算0-1放缩参数
            % y=(x-b)/a
            a=line_y(j-1)-line_y(flag_start);
            b=line_y(flag_start);
            for k=flag_start:j-1
                % apply_power
                line_y(k)=(line_y(k)-b)/a;% 放缩to0-1
                % 分正负处理
                if line_y(k)>=0
                    line_y(k)=line_y(k)^power(i);
                else % 避免虚数
                    line_y(k)=-(-line_y(k))^power(i);
                end
                line_y(k)=a*line_y(k)+b;% 放缩from0-1
            end
            flag_start=j;
            break;
        end
    end
end

end
