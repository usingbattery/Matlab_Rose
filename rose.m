classdef Rose
    properties
         % 花朵通用参数
        fineness=1;% 渲染精细度
        flower_position=[0,0,0];% 花托点位置
        flower_size=1;% 放大倍数
        petal_number=8;% 花瓣数量
        % 花瓣控制参数
        petal_size;% 尺寸大小[size_x,size_y,size_z;...]
        petal_pixel;% 像素点数[pixel_xy,pixel_z;...]
        petal_theta;% 起止角度[theta_start,theta_end;...]
        petal_radius_z;% 母线函数radius_z[][]
        petal_fillet;% 圆角函数fillet[][]
        petal_color;% 颜色基色[red,green,blue,dark;...]
        petal_line_c;% 边色基色[red,green,blue;...]
    end
    properties(Hidden)
    	% 玫瑰特征参数
        petal_ratio=[1,1,1];% 花瓣大小比例
        petal_theta_range=270;% 花瓣角度大小
        petal_inflexion_point=[% 花瓣竖向曲线拐点
            0,0.32,0.6,1;
            0,1,0.85,1.15];
        petal_inflexion_power=[1/6;1;1];% 花瓣径向凹凸程度(凹nan——0凸)
    end
    methods
        % 构造函数
        function this=Rose(fineness,flower_position,flower_size,petal_number)
            % 参数录入
            this.fineness=fineness;
            this.flower_position=flower_position;
            this.flower_size=flower_size;
            this.petal_number=max(0,round(petal_number));
            % 参数计算
            this.petal_size=this.Get_Petal_Size();
            this.petal_pixel=this.Get_Petal_PixelNum();
            this.petal_theta=this.Get_Petal_Theta();
            this.petal_radius_z=this.Get_Petal_Radius_z();
            this.petal_fillet=this.Get_Petal_Fillet();
            this.petal_color=this.Get_Petal_Color();
            this.petal_line_c=this.Get_Petal_Line_C();
        end
        % 渲染图像
        function Render(this)
            % 渲染花朵
            for petal_sequence=1:this.petal_number
                % 生成并渲染花瓣
                petal_rose=this.Get_Petal(petal_sequence);
                petal_rose.Render();
            end
            % 关闭网格
            shading interp;
        end
        % 花瓣生成
        function petal_rose=Get_Petal(this,petal_sequence)
            % 数据准备
            size=this.petal_size(petal_sequence,:);
            pixel=this.petal_pixel(petal_sequence,:);
            theta=this.petal_theta(petal_sequence,:);
            radius_z=this.petal_radius_z(petal_sequence,:);
            fillet=this.petal_fillet(petal_sequence,:);
            color=this.petal_color(petal_sequence,:);
            line_c=this.petal_line_c(petal_sequence,:);
            % 花瓣生成
            petal_rose=Petal(size,pixel,theta,radius_z,fillet,color,line_c);
        end
        % 花瓣大小计算
        function petal_size=Get_Petal_Size(this)
            petal_size=zeros(this.petal_number,3);
            for petal_sequence=1:this.petal_number(1)
                size_x=this.petal_ratio(1)*this.flower_size*sin(petal_sequence/this.petal_number(1))/sin(1);
                size_y=this.petal_ratio(2)*this.flower_size*sin(petal_sequence/this.petal_number(1))/sin(1);
                A=0.15;
                size_z=this.flower_size*(1-A+A*(sin((petal_sequence/this.petal_number(1))*pi)+petal_sequence/this.petal_number(1)));
                % 集成输出
                petal_size(petal_sequence,:)=[size_x,size_y,size_z];
            end
        end
        % 花瓣像素数计算
        function petal_pixel=Get_Petal_PixelNum(this)
            petal_pixel=zeros(this.petal_number,2);
            for petal_sequence=1:this.petal_number(1)
                % 数据运算
                pixel_xy=16*(this.petal_theta_range/180)*this.fineness;
                A=0.2;
                pixel_xy=pixel_xy*(A+(1-A)*petal_sequence/this.petal_number(1))+1;
                pixel_z=16*this.petal_ratio(3)*this.fineness+1;
                % 数据规范
                pixel_xy=max(3,round(pixel_xy));
                pixel_z=max(2,round(pixel_z));
                % 集成输出
                petal_pixel(petal_sequence,:)=[pixel_xy,pixel_z];
            end
        end
        % 花瓣角度计算
        function petal_theta=Get_Petal_Theta(this)
            petal_theta=zeros(this.petal_number,2);
            theta_start_random=32;
            theta_range_random=32;
            for petal_sequence=1:this.petal_number(1)
                theta_start=150*petal_sequence+unifrnd(-theta_start_random,theta_start_random);
                theta_start=rem(theta_start,360);
                theta_range=this.petal_theta_range+unifrnd(-theta_range_random,theta_range_random);
                % 集成输出
                petal_theta(petal_sequence,:)=[theta_start,theta_start+theta_range]./180.*pi;
            end
        end
        % 花瓣半径计算
        function petal_radius_z=Get_Petal_Radius_z(this)
            pixel_z=max(this.petal_pixel(:,2));
            petal_radius_z=zeros(this.petal_number,pixel_z);
            for petal_sequence=1:this.petal_number(1)
                pixel_z=this.petal_pixel(petal_sequence,2);
                r_z=Curve_cos_power(this.petal_inflexion_point,this.petal_inflexion_power,0,1,pixel_z);
                % 集成输出
                petal_radius_z(petal_sequence,1:pixel_z)=r_z;
            end
        end
        % 花瓣圆角计算
        function petal_fillet=Get_Petal_Fillet(this)
            pixel_xy=max(this.petal_pixel(:,1));
            petal_fillet=zeros(this.petal_number,pixel_xy);
            for petal_sequence=1:this.petal_number(1)
                pixel_xy=this.petal_pixel(petal_sequence,1);
                xy=linspace(-1,1,pixel_xy+2);
                fillet_=1-xy.^4;
                fillet_=fillet_(2:pixel_xy+1);
                % 集成输出
                petal_fillet(petal_sequence,1:pixel_xy)=fillet_;
            end
        end
        % 花瓣颜色计算
        function petal_color=Get_Petal_Color(this)
            petal_color=zeros(this.petal_number,4);
            color_=[0.67,0,0,0.36];
            for petal_sequence=1:this.petal_number(1)
                petal_color(petal_sequence,:)=color_;
            end
        end
        % 花瓣边色计算
        function petal_line_color=Get_Petal_Line_C(this)
            petal_line_color=zeros(this.petal_number,3);
            color_=[0.67,0,0];
            for petal_sequence=1:this.petal_number(1)
                % 集成输出
                petal_line_color(petal_sequence,:)=color_;
            end
        end
    end
end
