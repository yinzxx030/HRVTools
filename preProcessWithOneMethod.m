function [Rtime, ECG, RtimeR, Rpeak, IBI, IBI_correction] = preProcessWithOneMethod(ECG, Fs, RDetectMethod)
%% 预处理数据：滤波+R峰检测

    % 中值滤波消除基线漂移,窗大小默认为采样率的30%
    ECG_fil_base = medianFilter(ECG, ceil((Fs*0.3-1)/2));

%     % 低通滤波器滤除工频干扰
%     ECG_filter = lowPassFilter(ECG_temp, Fs);

    % 小波变换去除工频噪声，使用db6小波进行5层分解，用第3、4层细节进行重构
    if Fs == 500
        [c,l] = wavedec(ECG_fil_base,5,'db6');
        ECG_fil_all = wrcoef('a',c,l,'db6',3);
    elseif Fs ==1000
        [c,l] = wavedec(ECG_fil_base,5,'db6');
        ECG_fil_all = wrcoef('a',c,l,'db6',4);
    elseif Fs ==100
        [c,l] = wavedec(ECG_fil_base,1,'db6');
        ECG_fil_all = wrcoef('a',c,l,'db6',1);
    elseif Fs ==200
        [c,l] = wavedec(ECG_fil_base,2,'db6');
        ECG_fil_all = wrcoef('a',c,l,'db6',2);
    end

    % 计算ECG横坐标时间
    Rtime = (1:length(ECG_fil_all)) / Fs;
    
    % R峰检测
    if strcmp(RDetectMethod, 'A')
        % pan_tompkin方法处理
        [~,R_loc,~,~,~,~] = pan_tompkin(ECG_fil_all,Fs,0);
        if isempty(R_loc)
            return;
        end
    elseif strcmp(RDetectMethod, 'B')
        % kota方法处理
        R_loc = kota(ECG_fil_all, ECG_fil_base, Fs);
        if isempty(R_loc)
            return;
        end
    elseif strcmp(RDetectMethod, 'C')
        % C方法处理
        [R_loc,~,~] = qrs_detect2(ECG_fil_all,0.25,0.6,Fs);
        if isempty(R_loc)
            return;
        end
    end 

    if isempty(R_loc)
        RtimeR = 0;
        Rpeak = 0;
        IBI(:,1) = 0;
        IBI(:,2) = 0;
        IBI_correction(:,1) = 0;
        IBI_correction(:,2) = 0;
        return;
    end
        
    RtimeR = R_loc / Fs;
    IBI(:,1) = RtimeR(2:end);
    IBI(:,2) = diff(RtimeR)';

    % 自动校正IBI
    if strcmp(RDetectMethod, 'A')
        R_loc = autoCorrection(Fs, ECG_fil_all, R_loc, 'PT');
    elseif strcmp(RDetectMethod, 'B')
        R_loc = autoCorrection(Fs, ECG_fil_all, R_loc, 'PT');
        R_loc = autoCorrection(Fs, ECG_fil_all, R_loc, 'kota');
    end

    RtimeR = R_loc / Fs;
    Rpeak = ECG_fil_all(R_loc);
    IBI_correction(:,1) = RtimeR(2:end);
    IBI_correction(:,2) = diff(RtimeR)';
end