classdef Rose<Flower
    
    % 玫瑰子类
    
    % 玫瑰的个性形状参数
    properties(Hidden)
        petal_ratio=[1.00,1.00,1.00];% 花瓣大小比例[直径x,直径y,高z]
        calyx_ratio=[1.08,1.08,0.32];% 花萼大小比例[直径x,直径y,高z]
        branch_ratio=[0.16,0.16,-3.6];% 花枝大小比例[直径x,直径y,高z]

        petal_theta_range=240;% 花瓣角度大小,角度制
        calyx_theta_range=50;% 花萼角度大小,角度制
        
        petal_inflexion=[% 花瓣轴向曲线参数
            % 因生成单位圆柱，故约定曲线范围0到1
            0,0.32,0.60,1.00;% 按列读坐标,首尾是端点
            0,1.00,0.85,1.15];% 中间坐标是曲线的拐点
        petal_inflexion_power=[1/4;1;1];% 花瓣径向凹凸,凹nan-凸0
        
        calyx_inflexion=[% 花萼轴向曲线参数
            % 因生成单位圆柱，故约定曲线范围0到1
            0,1;% 按列读坐标,首尾是端点
            0,1];% 中间坐标是曲线的拐点
        calyx_inflexion_power=1/6;% 花萼径向凹凸,凹nan-凸0
        
        petal_baseColor=[0.67,0.00,0.00,0.36];% 花瓣颜色基色[R,G,B,Dark]
        calyx_baseColor=[0.00,0.67,0.00,0.30];% 花萼颜色基色[R,G,B,Dark]
        branch_baseColor=[0,0.67,0];% 花枝颜色基色[RGB]
        
        petal_line_color_=[0.67,0.00,0];% 花瓣边色基色[RGB]
        calyx_line_color_=[0.00,0.37,0];% 花萼边色基色[RGB]
    end
    
    methods
        % 构造函数
        function this=Rose(fineness,flower_position,flower_size,petal_number,calyx_number)
            this=this@Flower(fineness,flower_position,flower_size,[petal_number,calyx_number]);
        end
        
        % 实例化方法
        
        % 花瓣大小计算
        function petal_size=get_petal_size(this)
            % 预分配内存
            petal_size=ones(sum(this.petal_number),3);
            
            % 花瓣数据计算
            for petal_sequence=1:this.petal_number(1)
                % 外紧内松
                size_x=this.petal_ratio(1,1)*this.flower_size*sin(petal_sequence/this.petal_number(1))/sin(1);
                size_y=this.petal_ratio(1,2)*this.flower_size*sin(petal_sequence/this.petal_number(1))/sin(1);
                % 
                A=0.15;
                size_z=this.petal_ratio(1,3)*this.flower_size*(1-A+A*(sin((petal_sequence/this.petal_number(1))*pi)+petal_sequence/this.petal_number(1)));
                % 集成输出
                petal_size(petal_sequence,:)=[size_x,size_y,size_z];
            end
            
            % 花萼数据计算
            for calyx_sequence=this.petal_number(1)+1:sum(this.petal_number)
                size_x=this.calyx_ratio(1,1)*this.flower_size;
                size_y=this.calyx_ratio(1,2)*this.flower_size;
                size_z=this.calyx_ratio(1,3)*this.flower_size;
                % 集成输出
                petal_size(calyx_sequence,:)=[size_x,size_y,size_z];
            end
        end
        
        % 花瓣像素数计算
        function petal_pixel=get_petal_pixel(this)
            % 预分配内存
            petal_pixel=ones(sum(this.petal_number),2);
            
            % 花瓣数据计算
            for petal_sequence=1:this.petal_number(1)
                % 数据运算
                pixel_xy=16*(this.petal_theta_range/180)*this.fineness;
                A=0.2;
                pixel_xy=pixel_xy*(A+(1-A)*petal_sequence/this.petal_number(1))+1;
                pixel_z=16*this.petal_ratio(1,3)*this.fineness+1;
                % 数据规范
                pixel_xy=max(3,round(pixel_xy));
                pixel_z=max(2,round(pixel_z));
                % 集成输出
                petal_pixel(petal_sequence,:)=[pixel_xy,pixel_z];
            end
            
            % 花萼数据计算
            for calyx_sequence=this.petal_number(1)+1:sum(this.petal_number)
                % 数据运算
                pixel_xy=16*(this.calyx_theta_range/180)*this.fineness+1;
                pixel_z=16*abs(this.calyx_ratio(1,3))*this.fineness+1;
                % 数据规范
                pixel_xy=max(3,round(pixel_xy));
                pixel_xy=pixel_xy+rem(pixel_xy,2)-1;
                pixel_z=max(2,round(pixel_z));
                % 集成输出
                petal_pixel(calyx_sequence,:)=[pixel_xy,pixel_z];
            end
        end
        
        % 花瓣角度计算
        function petal_theta=get_petal_theta(this)
            % 预分配内存
            petal_theta=ones(sum(this.petal_number),2);
            
            % 随机量,未纳入控制,关闭
            theta_start_random=0;% 比例,0-1
            theta_range_random=0;% 比例,0-1
            
            % 花瓣数据计算
            for petal_sequence=1:this.petal_number(1)
                % 等差生成theta_start,未纳入控制
                theta_start=150*petal_sequence;
                theta_start=theta_start*(1+unifrnd(-theta_start_random,theta_start_random));
                theta_start=rem(theta_start,360);
                % 生成theta_range
                theta_range=this.petal_theta_range*(1+unifrnd(-theta_range_random,theta_range_random));
                % 集成输出
                petal_theta(petal_sequence,:)=[theta_start,theta_range];
            end
            
            % 花萼数据计算
            calyx_number=this.petal_number(2);
            for calyx_sequence=this.petal_number(1)+1:sum(this.petal_number)
                % 均分整圆周生成theta_start
                theta_start=(360/calyx_number)*calyx_sequence;
                theta_start=theta_start*(1+unifrnd(-theta_start_random,theta_start_random));
                theta_start=rem(theta_start,360);
                % 生成theta_range
                theta_range=this.calyx_theta_range*(1+unifrnd(-theta_range_random,theta_range_random));
                % 集成输出
                petal_theta(calyx_sequence,:)=[theta_start,theta_range];
            end
        end
        
        % 花瓣半径计算
        function petal_radius_z=get_petal_radius_z(this)
            % 预分配内存
            pixel_z=max(this.petal_pixel(:,2));
            petal_radius_z=zeros(sum(this.petal_number),pixel_z);
            
            % 花瓣数据计算
            for petal_sequence=1:this.petal_number(1)
                % 数据准备
                point=this.petal_inflexion;
                
                point_num=size(point,2);
                point_begin=2*point(:,1)-point(:,2);
                point_end=2*point(:,point_num)-point(:,point_num-1);
                point=[point_begin,point(:,2:point_num-1),point_end];
                
                power=this.petal_inflexion_power;
                
                pixel_z=this.petal_pixel(petal_sequence,2);
                
                % 数据计算
                r_z=Curve_cos_power(point,power,0,1,pixel_z);
                
                % 集成输出
                petal_radius_z(petal_sequence,1:pixel_z)=r_z;
            end
            
            % 花萼数据计算
            for calyx_sequence=this.petal_number(1)+1:sum(this.petal_number)
                % 数据准备
                point=this.calyx_inflexion;
                
                point_num=size(point,2);
                point_begin=2*point(:,1)-point(:,2);
                point=[point_begin,point(:,2:point_num)];
                
                power=this.calyx_inflexion_power;
                
                pixel_z=this.petal_pixel(calyx_sequence,2);

                % 数据计算
                r_z=Curve_cos_power(point,power,0,1,pixel_z);
                
                % 集成输出
                petal_radius_z(calyx_sequence,1:pixel_z)=r_z;
            end
        end
        
        % 花瓣圆角计算
        function petal_fillet=get_petal_fillet(this)
            % 预分配内存
            pixel_xy=max(this.petal_pixel(:,1));
            petal_fillet=ones(sum(this.petal_number),pixel_xy);
            
            % 花瓣数据计算
            for petal_sequence=1:this.petal_number(1)
                pixel_xy=this.petal_pixel(petal_sequence,1);
                % 在两端为0预留位置，稍后裁去
                xy=linspace(-1,1,pixel_xy+2);

                % 因生成单位圆柱，故约定曲线范围0到1
                fillet_=1-xy.^4;
                fillet_=fillet_(2:pixel_xy+1);
                % 集成输出
                petal_fillet(petal_sequence,1:pixel_xy)=fillet_;
            end
            
            % 花萼数据计算
            for calyx_sequence=this.petal_number(1)+1:sum(this.petal_number)
                pixel_xy=this.petal_pixel(calyx_sequence,1);
                % 在两端为0预留位置，稍后裁去
                xy=linspace(-1,1,pixel_xy+2);

                % 因生成单位圆柱，故约定曲线范围0到1
                fillet_=1-sqrt(abs(xy));
                fillet_=fillet_(2:pixel_xy+1);
                % 集成输出
                petal_fillet(calyx_sequence,1:pixel_xy)=fillet_;
            end
        end
        
        % 花瓣颜色计算
        function petal_color=get_petal_color(this)
            % 预分配内存
            petal_color=ones(sum(this.petal_number),4);
            
            % 花瓣数据计算
            for petal_sequence=1:this.petal_number(1)
                petal_color(petal_sequence,:)=this.petal_baseColor;
            end
            
            % 花萼数据计算
            for calyx_sequence=this.petal_number(1)+1:sum(this.petal_number)
                petal_color(calyx_sequence,:)=this.calyx_baseColor;
            end
        end
        
        % 花瓣边色计算
        function petal_line_c=get_petal_line_c(this)
            % 预分配内存
            petal_line_c=ones(sum(this.petal_number),3);
            
            % 花瓣数据计算
            for petal_sequence=1:this.petal_number(1)
                petal_line_c(petal_sequence,:)=this.petal_line_color_;
            end
            
            % 花萼数据计算
            for calyx_sequence=this.petal_number(1)+1:sum(this.petal_number)
                petal_line_c(calyx_sequence,:)=this.calyx_line_color_;
            end
        end
        
        % 花瓣位置计算
        function petal_position=get_petal_position(this)
            % 预分配内存
            petal_position=ones(sum(this.petal_number),3);
            
            % 花瓣数据计算
            for petal_sequence=1:this.petal_number(1)
                position_=[0,0,0];
                petal_position(petal_sequence,:)=this.flower_position+this.flower_size*position_;
            end
            
            % 花萼数据计算
            for calyx_sequence=this.petal_number(1)+1:sum(this.petal_number)
                position_=[0,0,-0.01];
                petal_position(calyx_sequence,:)=this.flower_position+this.flower_size*position_;
            end
        end
        
        % 花枝大小计算
        function branch_size=get_branch_size(this)
            size_x=0.5*this.branch_ratio(1)*this.flower_size;
            size_y=0.5*this.branch_ratio(2)*this.flower_size;
            size_z=this.branch_ratio(3)*this.flower_size;
            
            branch_size=[size_x,size_y,size_z];
        end
        
        % 花枝像素数计算
        function branch_pixel=get_branch_pixel(this)
            % 数据运算
            pixel_xy=8*(this.branch_ratio(1)+this.branch_ratio(2))*pi*this.fineness+1;
            pixel_z=16*abs(this.branch_ratio(3))*this.fineness+1;
            % 数据规范
            pixel_xy=max(4,round(pixel_xy));
            pixel_z=max(2,round(pixel_z));
            
            branch_pixel=[pixel_xy,pixel_z];
        end
        
        % 花枝半径计算
        function branch_radius_z=get_branch_radius_z(this)
            branch_radius_z=ones(this.branch_pixel(2),1);
        end
        
        % 花枝轴线偏移计算
        function branch_curve=get_branch_curve(this)
            m=this.branch_pixel(2);
            branch_curve=ones(m+1,1);
            branch_curve(1)=unifrnd(0,360);
            for i=2:m+1
                curve_=1-cos((pi/2)*((i-1)/m));
                branch_curve(i)=0.5*this.flower_size*curve_;
            end
        end
        
        % 花枝颜色计算
        function branch_color=get_branch_color(this)
            branch_color=this.branch_baseColor;
        end
        
        % 花枝位置计算
        function branch_position=get_branch_position(this)
            position_=[0,0,0];
            branch_position=this.flower_position+position_;
        end
        
        % set方法
        
        % 设置花瓣大小比例
        function this=set.petal_ratio(this,petal_ratio)
            this.petal_ratio=petal_ratio;
        end
        
        % 设置花萼大小比例
        function this=set.calyx_ratio(this,calyx_ratio)
            this.calyx_ratio=calyx_ratio;
        end
        
        % 设置花枝大小比例
        function this=set.branch_ratio(this,branch_ratio)
            this.branch_ratio=branch_ratio;
        end
        
        % 设置花瓣角度大小
        function this=set.petal_theta_range(this,petal_theta_range)
            this.petal_theta_range=max(0,petal_theta_range);
        end
        
        % 设置花萼角度大小
        function this=set.calyx_theta_range(this,calyx_theta_range)
            this.calyx_theta_range=max(0,calyx_theta_range);
        end
        
        % 设置花瓣轴向曲线参数
        function this=set.petal_inflexion(this,petal_inflexion)
            this.petal_inflexion=petal_inflexion;
        end
        
        % 设置花瓣径向凹凸
        function this=set.petal_inflexion_power(this,petal_inflexion_power)
            this.petal_inflexion_power=max(0,petal_inflexion_power);
        end
        
        % 设置花萼轴向曲线参数
        function this=set.calyx_inflexion(this,calyx_inflexion)
            this.calyx_inflexion=calyx_inflexion;
        end
        
        % 设置花萼径向凹凸
        function this=set.calyx_inflexion_power(this,calyx_inflexion_power)
            this.calyx_inflexion_power=max(0,calyx_inflexion_power);
        end
        
        % 设置花瓣颜色基色
        function this=set.petal_baseColor(this,petal_baseColor)
            this.petal_baseColor=petal_baseColor;
        end
        
        % 设置花萼颜色基色
        function this=set.calyx_baseColor(this,calyx_baseColor)
            this.calyx_baseColor=calyx_baseColor;
        end
        
        % 设置花枝颜色基色
        function this=set.branch_baseColor(this,branch_baseColor)
            this.branch_baseColor=branch_baseColor;
        end
        
        % 设置花瓣边色基色
        function this=set.petal_line_color_(this,petal_line_color_)
            this.petal_line_color_=petal_line_color_;
        end
        
        % 设置花萼边色基色
        function this=set.calyx_line_color_(this,calyx_line_color_)
            this.calyx_line_color_=calyx_line_color_;
        end
    end
end
