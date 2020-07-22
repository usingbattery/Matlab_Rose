classdef Petal
    
    % 花瓣引擎
    %#ok<*NASGU>
    %#ok<*CPROPLC>
    
    properties
        size;% [size_x,size_y,size_z]
        pixel;% [pixel_xy,pixel_z]
        theta;% [theta_start,theta_range]
        
        radius_z;% radius_z[]
        fillet;% fillet[]
        
        color;% [color_x,color_y,color_z]
        line_c;% [linec_x,linec_y,linec_z]
        
        position;% [position_x,position_y,position_z]
    end
    
    methods
        % 构造函数
        function this=Petal(size,pixel,theta,radius_z,fillet,color,line_c,position)
            this.size=size;
            this.pixel=pixel;
            this.theta=theta;
            
            this.radius_z=radius_z;
            this.fillet=fillet;
            
            this.color=color;
            this.line_c=line_c;
            
            this.position=position;
        end
        
        % 渲染图像
        function Render(this)
            [x,y,z,c]=this.Get_Matrix();
            surf(x,y,z,c);
            
            this.OutLine(x,y,z);
        end
        
        % 矩阵生成
        function [x,y,z,c]=Get_Matrix(this)
            % 获取基本矩阵
            [x,y,z]=this.Get_Cylinder();
            
            % 剪裁圆角
            [x,y,z]=this.TrimFillet(x,y,z);
            
            % 获取颜色
            c=this.Get_Color(z);
                        
            % 调节大小
            [x,y,z]=this.ApplySize(x,y,z);
            
            % 调整位置
            [x,y,z]=this.ApplyPosition(x,y,z);
        end
        
        % 描边
        function OutLine(this,x,y,z)
            % 描上边
            m=this.pixel(2);
            n=this.pixel(1);
            
            lx=ones(1,n);
            ly=ones(1,n);
            lz=ones(1,n);
            
            for j=1:n
                i=2;
                while i<=m&&~isnan(z(i,j))
                    i=i+1;
                end
                lx(j)=x(i-1,j);
                ly(j)=y(i-1,j);
                lz(j)=z(i-1,j);
            end
            plot3(lx,ly,lz,'Color',this.line_c);
            
            % 描侧边
            % 备注：可以优化。
            plot3(x(:,1),y(:,1),z(:,1),'Color',this.line_c);
            plot3(x(:,n),y(:,n),z(:,n),'Color',this.line_c);
        end
        
        % 基本柱面生成
        function [x,y,z]=Get_Cylinder(this)
            % 数据准备
            thetas=this.Get_Theta();
            r=this.radius_z(1:this.pixel(2));
            
            % 数据规范
            thetas=thetas/180*pi;
            r=r';
            
            % 曲柱面生成
            x=r*cos(thetas);
            y=r*sin(thetas);
            
            m = length(r);
            n = length(thetas);
            z = (0:m-1)'/(m-1) * ones(1,n);
        end
        
        % 剪裁圆角
        function [x,y,z]=TrimFillet(this,x,y,z)
            % 高耗时!
            % 0.034s=0.014+0.010+0.010;
            
            m=this.pixel(2);
            n=this.pixel(1);
            
            % 精准点校准
            lambd=0;
            edge_z=0;
            for j=1:n
                edge_z=this.fillet(j);
                for k=1:m
                    if (z(k,j)==edge_z)
                        break;
                    elseif (z(k,j)>edge_z)
                        lambd=(edge_z-z(k-1,j))/(z(k,j)-z(k-1,j));
                        x(k,j)=x(k-1,j)+lambd*(x(k,j)-x(k-1,j));
                        y(k,j)=y(k-1,j)+lambd*(y(k,j)-y(k-1,j));
                        z(k,j)=edge_z;
                        break;
                    end
                end
            end
            
            % 逐列镂空
            for j=1:n
                edge_z=this.fillet(j);
                for k=1:m
                    if (z(k,j)>edge_z)
                        x(k,j)=nan;
                        y(k,j)=nan;
                        z(k,j)=nan;
                    end
                end
            end
            
            % 三角填充
            left_begin=1;
            left_end=floor(n/2);
            
            right_begin=n;
            right_end=left_end+1;
            
            begins=[left_begin,right_begin];
            ends=[left_end,right_end];
            directions=[1,-1];
            % 从左右侧向中心
            for i=[1,2]
                for j=begins(i):directions(i):ends(i)
                    for k=1:m
                        if (isnan(z(k,j))&&~isnan(z(k,j+directions(i))))
                            x(k,j)=x(k-1,j);
                            y(k,j)=y(k-1,j);
                            z(k,j)=z(k-1,j);
                        end
                    end
                end
            end
        end
        
        % 颜色生成
        function c=Get_Color(this,z)
            m=this.pixel(1);
            n=this.pixel(2);
            % 颜色矩阵
            color_0=ones(size(z,1),size(z,2));
            
            % 渐变优化
            for j=1:m
                % 边缘渐变
                hard_xy=0.35;
                hard_xy=hard_xy*this.color(4)*(j-0.5*(1+m))^2/((1-0.5*(1+m))^2);
                dark_hard=this.color(4)-hard_xy;
                for i=1:n
                    % 上下渐变
                    color_=z(i,j)/this.fillet(j);
                    % 暗度调整
                    color_=dark_hard*color_;
                    % 输出颜色
                    color_0(i,j)=1-color_;
                end
            end
            
            % 集成输出
            c(:,:,1)=this.color(1)*color_0;
            c(:,:,2)=this.color(2)*color_0;
            c(:,:,3)=this.color(3)*color_0;
        end
        
        % 调整大小
        function [x,y,z]=ApplySize(this,x,y,z)
            x=0.5*this.size(1)*x;
            y=0.5*this.size(2)*y;
            z=this.size(3)*z;
        end
        
        % 调整位置
        function [x,y,z]=ApplyPosition(this,x,y,z)
            x=x+this.position(1);
            y=y+this.position(2);
            z=z+this.position(3);
        end
        
        % 角度计算
        function thetas=Get_Theta(this)
            % 数据准备
            theta_start=this.theta(1);
            theta_range=this.theta(2);
            theta_number=this.pixel(1);
            
            % 输出
            thetas=linspace(theta_start,theta_start+theta_range,theta_number);
        end
    end
end
