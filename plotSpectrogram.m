    function plotSpectrogram(aH,fs,TFoutput, VLF,LF,HF,limX,limY,flag,Methods, nIBI)
    % plotSpectrogram: plots a spectrogram in the given axis handle (aH)
    %
    % Inputs:
    %   aH: axis handle to use for plotting
    %   T,F,PSD: time, freq, and psd arrays
    %   TFoutput结构体中包含hrvAnalyse.m中了利用timeFreq.m计算出的T,F,PSD结果
    %   VLF, LF, HF: VLF, LF, HF freq bands
    %   plotType: type of plot to produce (mesh, surf, or image)
    %   flagWavelet: (true/false) determines if psd is from wavelet
    %   transform. Wavelet power spectrum requires log scale    
         
        if (nargin < 11), flag=false; end  

        for m=1:length(Methods)
        if strcmp(Methods,'ar')
            flagwav = false;
            T = TFoutput.ar.t;
            PSD = TFoutput.ar.psd;
            F = TFoutput.ar.f;
        elseif strcmp(Methods,'lomb')
            flagwav = false;
            T = TFoutput.lomb.t;
            PSD = TFoutput.lomb.psd;
            F = TFoutput.lomb.f;
        elseif strcmp(Methods,'wavelet')
            flagwav = true;
            T = TFoutput.wav.t;
            PSD = TFoutput.wav.psd;
            F = TFoutput.wav.f;
        end
        end

        %convert to period, see wavelet code for reasons
        if flagwav
          F=1./F; 
%           datainf=isinf(F);
%           [inf_r, ~] = find(datainf==1);
%           F(inf_r, :)= [];
%           F(inf_r, :)=max(F);

        end 
        
        cla(aH,"reset")   
        PSD=PSD./(1000^2); %convert to s^2/hz or s^2                
        xlimit=[nIBI(1,1) nIBI(end,1)];
                        
        T = linspace(T(1),T(end), round(length(T)));
        T = round(T);
        if flagwav
            %surf(aH,T,log2(F),PSD,"FaceColor","interp","EdgeColor","flat");
            imagesc(aH,T,log2(F),PSD);
            colormap(aH,jet);
            set(aH,'ydir','reverse');
        else
            nT=100; %define number of time points to plot. This will 
                    %be used to interpolate a smoother spectrogram image.
            T2=linspace(T(1),T(end),nT); %linear spaced time values
            %T2 = T(1):1/fs :T(end);
            PSD=interp2(T,F,PSD,T2,F); %bilinear interpolation
            %PSD=interp2(PSD,T2,F);
            %surf(aH,T2,F,PSD,"FaceColor","interp","EdgeColor","flat");
            imagesc(aH,T2,F,PSD);
            colormap(aH,jet);
            set(aH,'ydir','norm','XLim', xlimit,'YLim',limY);
        end
        
        %add colorbar
        %colorbar;
        
        %draw lines for vlf, lf, and hf bands
        x=xlimit'; x=[x,x,x];
        y=[VLF(2),LF(2),HF(2)]; y=[y;y];
        z=max(max(PSD(:,:))); z=[z,z,z;z,z,z];
        if flagwav
            y=log2(1./y); %log2 of period
            Yticks = 2.^(fix(log2(min(F))):fix(log2(max(F))));
            YtickLabels=cell(size(Yticks));
            for i=1:length(Yticks)
                YtickLabels{i}=num2str(1./Yticks(i),'%0.3f');
            end
            set(aH,'YLim',log2([min(Yticks) max(Yticks)]), ...
                'YTick',log2(Yticks(:)), 'YTickLabel',YtickLabels);
        end        
        %set(aH,line(x,y,z),'color',[1 1 1]);

    end