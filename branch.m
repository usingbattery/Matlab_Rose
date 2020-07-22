classdef Branch
    
    % 枝干引擎
    %#ok<*PROPLC>
    
    properties
        size;% [size_x,size_y,size_z]
        pixel;% [pixel_xy,pixel_z]
        radius_z;% 花枝半径radius_z[]
        curve;% 花枝弯曲线[方向,幅度[]]
        color;% [color_x,color_y,color_z]
        position;% 起始端的圆心坐标[position_x,position_y,position_z]
    end

    methods
        % 构造函数
        function this=Branch(size,pixel,radius_z,curve,color,position)
            this.size=size;
            this.pixel=pixel;
            this.radius_z=radius_z;
            this.curve=curve;
            this.color=color;
            this.position=position;
        end
        
        % 渲染图像
        function Render(this)
            [x,y,z,c]=this.Get_Matrix();
            surf(x,y,z,c);
        end
        
        % 矩阵生成
        function [x,y,z,c]=Get_Matrix(this)
            % 获取基本矩阵
            [x,y,z]=this.Get_Cylinder();
            
            % 颜色生成
            c=this.Get_Color();
            
            % 调节大小
            [x,y,z]=this.ApplySize(x,y,z);
            
            % 调节曲线
            [x,y,z]=this.ApplyCurve(x,y,z);
            
             % 调节位置
            [x,y,z]=this.ApplyPosition(x,y,z);
        end
        
        % 基本柱面生成
        function [x,y,z]=Get_Cylinder(this)
            [x,y,z]=cylinder(this.radius_z,this.pixel(1)-1);
        end
        
        % 颜色生成
        function c=Get_Color(this)
            color_0=ones(this.pixel(2),this.pixel(1));
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
        
        % 调整弯曲线
        function [x,y,z]=ApplyCurve(this,x,y,z)
            theta=this.curve(1);
            curve=this.curve(2:this.pixel(2)+1);
            
            curve_x=cos(theta)*curve;
            curve_y=sin(theta)*curve;
            
            [~,curve_x]=meshgrid(ones(1,this.pixel(1)),curve_x);
            [~,curve_y]=meshgrid(ones(1,this.pixel(1)),curve_y);

            x=x+curve_x;
            y=y+curve_y;
        end
        
        %调整位置
        function [x,y,z]=ApplyPosition(this,x,y,z)
            x=x+this.position(1);
            y=y+this.position(2);
            z=z+this.position(3);
        end
    end
end
