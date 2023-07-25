    function plotTF(UIAxesTF,tf,settings,nIBI)
%         showStatus('< Plotting TF >');
        
        m='Burg';
        if  strcmp(m,'Burg')
            psd=tf.ar.psd;
            globalPsd=tf.ar.global.psd;
            f=tf.ar.f;
            t=tf.ar.t;
            lf=tf.ar.hrv.aLF;
            hf=tf.ar.hrv.aHF;           
            %interpolate lf/hf time series for a smoother plot
            t2 = linspace(t(1),t(end),100); %time values for interp.
            if size(psd,2)>1
                %interpolation
                lfhf=interp1(t,tf.ar.hrv.LFHF,t2,'spline')'; 
            end
            %ylbl='PSD (ms^2/Hz)';
            flagVLF=true; %plot vlf in global PSD
        elseif strcmp(m, 'LS')
            psd=tf.lomb.psd;
            globalPsd=tf.lomb.global.psd;
            f=tf.lomb.f;
            t=tf.lomb.t;
            lf=tf.lomb.hrv.aLF;
            hf=tf.lomb.hrv.aHF;
            %interpolate lf/hf time series for a smoother plot
            t2 = linspace(t(1),t(end),100); %time values for interp.
            if size(psd,2)>1
                %interpolation
                lfhf=interp1(t,tf.lomb.hrv.LFHF,t2,'spline')';
            end
            %ylbl='PSD (ms^2/Hz)';
            flagVLF=true; %plot vlf in global PSD
        else            
            psd=tf.wav.psd;
            globalPsd=tf.wav.global.psd;
            f=tf.wav.f;
            t=tf.wav.t; t2=t;
            lf=tf.wav.hrv.aLF;
            hf=tf.wav.hrv.aHF;
            lfhf=tf.wav.hrv.LFHF;
            %ylbl='PSD (normalized)';
            flagVLF=false; %do not plot vlf in global PSD            
        end
        
        % temp: only plot from 0-0.6 Hz
        freqLim=1.1*settings.HF(end);
        fi=(f<=freqLim);
        f=f(fi);
        psd=psd(fi,:);
        globalPsd=globalPsd(fi);
        
        %Type of plot (spectrogram, global PSD, etc.)
        pt='spectrogram';
        switch lower(pt)
            case {'spectrogram', 'spectrogram (log)'}
                if strcmpi(pt,'spectrogram (log)')
                    psd=log(psd); %take log
                end
                plotSpectrogram(UIAxesTF,t,f,psd,settings.VLF, ...
                    settings.LF,settings.HF,[],[],strcmp(m,'Wavelet'),nIBI);
                xlabel(UIAxesTF,'Time (s)');
                ylabel(UIAxesTF,'Freq (Hz)');                                 
%             case 'surface'
%                 plotWaterfall(UIAxesTF,t,f,psd,settings.VLF, ...
%                     settings.LF,settings.HF,'surf',strcmp(m,'Wavelet'))
%                 xlabel(UIAxesTF,'Time (s)');
%                 ylabel(UIAxesTF,'Freq (Hz)');
%                 zlabel(UIAxesTF,'PSD (s^2/Hz)')
%                 %set event to copy fig on dblclick
%                 set(h.axesFreq,'ButtonDownFcn',@copyParentAxes);
%             case 'waterfall'
%                 plotWaterfall(UIAxesTF,t,f,psd,settings.VLF, ...
%                     settings.LF,settings.HF,'waterfall',strcmp(m,'Wavelet'))
%                 xlabel(UIAxesTF,'Time (s)');
%                 ylabel(UIAxesTF,'Freq (Hz)');
%                 zlabel(UIAxesTF,'PSD (s^2/Hz)')
%                 %set event to copy fig on dblclick
%                 set(h.axesFreq,'ButtonDownFcn',@copyParentAxes);
%             case 'global psd'                
%                 plotPSD(UIAxesTF,f,globalPsd,settings.VLF, ...
%                     settings.LF,settings.HF,[],[],flagVLF);                    
%                 xlabel(UIAxesTF,'Freq (Hz)');
%                 ylabel(UIAxesTF,'Global PSD (s^2/Hz)');
%             case 'lf & hf power'
%                 plot(UIAxesTF,t,lf,'r');
%                 hold(UIAxesTF,'on');
%                 plot(UIAxesTF,t,hf,'b');
%                 hold(UIAxesTF,'off');
%                 xlabel(UIAxesTF,'Time (s)');
%                 ylabel(UIAxesTF,'Power (ms^2)');
%                 legend({'LF','HF'})
%                 set(UIAxesTF,'ButtonDownFcn',@copyAxes);
%                 xlim(UIAxesTF,[t(1) t(end)])
%             case 'lf/hf ratio'
%                 above=((lfhf>1).*lfhf);
%                 above(above==0)=1;
%                 below=((lfhf<1).*lfhf);
%                 below(below==0)=1;                 
%                 area(t2,above,'basevalue',1,'facecolor','c')
%                 hold(UIAxesTF,'on')
%                 area(t2,below,'basevalue',1,'facecolor','m')
%                 hold(UIAxesTF,'off')                                                
%                 xlabel(UIAxesTF,'Time (s)');
%                 ylabel(UIAxesTF,'LF/HF (ratio)');
%                 set(UIAxesTF,'ButtonDownFcn',@copyAxes);
        end
        
        %set axes font sizes. This is a temp fix.
%         set(UIAxesTF,'fontsize',7);
%         a = get(UIAxesTF,'XTickLabel');
%         set(UIAxesTF,'XTickLabel',a,'fontsize',7)
        
%         showStatus('');
    end

%     function showStatus(string)
%         if nargin < 1
%             string='';
%         end
%         
%         if isempty(string)
%             set(h.lblStatus,'visible','off','String','');
%         else
%             set(h.lblStatus,'visible','on','String',string);
%         end
%         drawnow expose;            
%     end