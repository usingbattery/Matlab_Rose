classdef Flower
    
    % 花朵父类
    
    % 花朵通用参数，构造时输入
    properties
        fineness=1;% 渲染精细度，分辨率
        flower_position=[0,0,0];% 位置,花萼根部坐标[x,y,z]
        flower_size=1;% 整体放大倍数
        petal_number=[8,4];% 花瓣数量[花瓣1,花瓣2,...]
    end
    
    % 花瓣控制参数，使用时计算
    properties(Hidden)
        petal_size;% 花瓣大小[size_x,size_y,size_z;...]
        petal_pixel;% 花瓣像素数量[pixel_xy,pixel_z;...]
        petal_theta;% 花瓣角度大小[theta_start,theta_range;...]
        petal_radius_z;% 花瓣母线radius_z[][]
        petal_fillet;% 花瓣圆角fillet[][]
        petal_color;% 花瓣颜色[red,green,blue,dark;...]
        petal_line_color;% 描边颜色[red,green,blue;...]
        petal_position;% 花瓣根部位置[position_x,position_y,position_z;...]
        branch_size;% 枝干大小[size_x,size_y,size_z]
        branch_pixel;% 枝干像素数量[pixel_xy,pixel_z]
        branch_radius_z;% 枝干母线radius_z[]
        branch_curve;% 枝干弯曲线[方向,幅度[]]
        branch_color;% 枝干颜色[red,green,blue]
        branch_position;% 枝干起始端点位置[x,y,z]
    end
    
    % 基本方法
    methods
        % 构造函数
        function this=Flower(fineness,flower_position,flower_size,petal_number)
            % 参数录入
            this.fineness=fineness;
            this.flower_position=flower_position;
            this.flower_size=flower_size;
            this.petal_number=petal_number;
        end
        
        % 渲染图像
        function Render(this)
            %参数计算
            this.petal_size=this.get_petal_size();
            this.petal_pixel=this.get_petal_pixel();
            this.petal_theta=this.get_petal_theta();
            this.petal_radius_z=this.get_petal_radius_z();
            this.petal_fillet=this.get_petal_fillet();
            this.petal_color=this.get_petal_color();
            this.petal_line_color=this.get_petal_line_c();
            this.petal_position=this.get_petal_position();
            this.branch_size=this.get_branch_size();
            this.branch_pixel=this.get_branch_pixel();
            this.branch_radius_z=this.get_branch_radius_z();
            this.branch_curve=this.get_branch_curve();
            this.branch_color=this.get_branch_color();
            this.branch_position=this.get_branch_position();
            
            % 渲染图像
            isholdon=ishold();% 缓存画板状态
            hold on;% 画板状态置为保持
            % 渲染花瓣
            for petal_sequence=1:sum(this.petal_number)
                petal=this.Get_Petal(petal_sequence);
                petal.Render();
            end
            % 渲染花枝
            branch_rose=this.Get_Branch();
            branch_rose.Render();
            shading interp;% 关闭网格
            if ~isholdon
                hold off;% 恢复画板状态
            end
        end
        
        %花瓣生成
        function petal=Get_Petal(this,petal_sequence)
            % 数据准备
            size=this.petal_size(petal_sequence,:);
            pixel=this.petal_pixel(petal_sequence,:);
            theta=this.petal_theta(petal_sequence,:);
            radius_z=this.petal_radius_z(petal_sequence,:);
            fillet=this.petal_fillet(petal_sequence,:);
            color=this.petal_color(petal_sequence,:);
            line_c=this.petal_line_color(petal_sequence,:);
            position=this.petal_position(petal_sequence,:);
            % 花瓣生成
            petal=Petal(size,pixel,theta,radius_z,fillet,color,line_c,position);
        end
        
        % 花枝生成
        function branch_rose=Get_Branch(this)
            % 数据准备
            size=this.branch_size;
            pixel=this.branch_pixel;
            radius_z=this.branch_radius_z;
            curve=this.branch_curve;
            color=this.branch_color;
            position=this.branch_position;
            % 枝干生成
            branch_rose=Branch(size,pixel,radius_z,curve,color,position);
        end
    end
    
    % 子类规范
    methods(Abstract)
        get_petal_size(this);
        get_petal_pixel(this);
        get_petal_theta(this);
        get_petal_radius_z(this);
        get_petal_fillet(this);
        get_petal_color(this);
        get_petal_line_c(this);
        get_petal_position(this);
        get_branch_size(this);
        get_branch_pixel(this);
        get_branch_radius_z(this);
        get_branch_curve(this);
        get_branch_color(this);
        get_branch_position(this);
    end
end
