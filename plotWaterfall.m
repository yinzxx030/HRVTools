function plotWaterfall(aH,T,F,PSD,VLF,LF,HF,plotType,flagWavelet)
    % plotWaterfall: creates a waterfall plot of consecutive PSD
    %绘制时频分析面板2中的'surface'与'waterfall'两种样式时频图
    % Inputs:
    %   aH: axis handle to use for plotting
    %   T,F,PSD: time, freq, and psd arrays
    %   VLF, LF, HF: VLF, LF, HF freq bands
    %   plotType: type of plot to produce (waterfall or surf)
    %   flagWavelet: (true/false) determines if psd is from wavelet
    %   transform. Wavelet power spectrum requires log scale
        
        if (nargin < 9), flagWavelet=false; end
        if (nargin < 8), plotType = 'surf'; end
        %convert to period, see wavelet code for reason
        if flagWavelet; F=1./F; end 
         
        %1.统一处理PSD、T、F
        PSD=PSD./(1000^2); %convert to s^2/hz or s^2
        PP=PSD;
        %PP(PP<-2)=-2; %to highlight the peaks, not giving visibility to
        %unnecessary valleys.        
        [TT,FF] = meshgrid(T,F);                
        
        %2.plot waterfall
        cla(aH,"reset")  %清空坐标区
        if flagWavelet; FF=log2(FF); end  %当为小波变换算法时，再次处理F（取log2）
        if strcmpi(plotType,'waterfall')            
            waterfall(aH, TT',FF',PP');
            aP=findobj(aH,'plotType','patch');
            set(aP,'FaceColor',[0.8314 0.8157 0.7843])
            %set(aH,'xdir','reverse');
        %OR plot 'surface'
        else
            surf(aH, TT,FF,PP,'parent',aH, 'LineStyle','none', 'FaceColor','interp');
            %set(aH,'xdir','reverse');
        end
        
        %3.determin axes limits定义坐标轴显示区间范围
        xlim=[min(T) max(T)];
        xrange=abs(max(xlim)-min(xlim)); dx=0.01*xrange;
        xlim=[xlim(1)-2*dx xlim(2)+dx]; % add 1% 
        ylim=[0 (HF(end)*1.1)];
        if flagWavelet
            ylim=[min(log2(F)) max(log2(F))];
        end 
        zlim=[min(min(PSD)) max(max(PSD))];
        zrange=abs(max(zlim)-min(zlim)); dz=0.01*zrange;
        zlim=[zlim(1)-dz zlim(2)+dz]; % add 1%
        
        %draw lines for vlf, lf, and hf bands along bottom
        %x=[xlim(1);xlim(2)];x=[x,x,x];
        %y=[VLF(2),LF(2),HF(2)];y=[y;y];
        %z=zlim(1); z=[z,z,z;z,z,z];
        %if flagWavelet; y=log2(1./y); end %log2 of period

        %set(aH, line(x,y,z),'color','black','linewidth',2);
        
        %draw vert lines for vlf, lf, and hf bands along back
%         x=[xlim(2);xlim(2)];x=[x,x,x];
         y=[VLF(2),LF(2),HF(2)];y=[y;y];
%         z=[zlim(1); zlim(2)]; z=[z,z,z];
        if flagWavelet
            y=log2(1./y); %log2 of period
            Yticks = 2.^(fix(log2(min(F))):fix(log2(max(F))));
            YtickLabels=cell(size(Yticks));
            for i=1:length(Yticks)
                YtickLabels{i}=num2str(1./Yticks(i),'%0.3f');
            end
            set(aH, 'YLim',log2([min(Yticks) max(Yticks)]), ...
                'YTick',log2(Yticks(:)),'YTickLabel',YtickLabels,'ydir','reverse');
%         else
%             Yticks = (fix(min(F)): fix(max(F)));
%             YtickLabels=cell(size(Yticks));
%             for i=1:length(Yticks)
%                 YtickLabels{i}=num2str(1./Yticks(i),'%0.2f');
%             end
%             set(aH, 'YLim',[min(Yticks) max(Yticks)], ...
%                 'YTick',Yticks(:),'YTickLabel',YtickLabels,'ydir','reverse');
        end        
        %set(line(x,y,z),'color','black','linewidth',2.5);
                
        %view(aH,100,35); %change 3d view切换三维图显示视角（此参数主要显示频率）
        %去除此行↑后，主要显示看时间角轴角度
        %set limits and flip x axis dir for better plotting       
        set(aH, 'zlim',zlim, 'xlim', xlim, 'ylim', ylim)


    end