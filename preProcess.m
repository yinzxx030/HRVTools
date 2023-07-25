function [Rtime, data_fil_all, RtimeR, Rpeak, IBI, IBI_correction] = preProcess(tag, DATA, Fs, IBIvarargin)
%% HRV预处理数据：滤波+R峰检测+自动校正
if strcmp(tag, 'ECG')
%     % 低通滤波器滤除工频干扰
%     ECG_fil_all = lowPassFilter(ECG_fil_base, Fs);
    if Fs == 500
    % 小波变换去除工频噪声，使用db6小波进行5层分解
        [c,l] = wavedec(DATA,3,'db6');
        data_fil = wrcoef('a',c,l,'db6',3);
    elseif Fs ==1000
        [c,l] = wavedec(DATA,4,'db6');
        data_fil = wrcoef('a',c,l,'db6',4);
    elseif Fs ==100
        [c,l] = wavedec(DATA,1,'db6');
        data_fil = wrcoef('a',c,l,'db6',1);
    elseif Fs ==200
        [c,l] = wavedec(DATA,2,'db6');
        data_fil = wrcoef('a',c,l,'db6',2);
    end

%     %梳状滤波器滤除谐波 未完成完整测试-待定
%     Fo = 50;
%     Q = 35; %品质因素
%     Wo = Fo/(Fs /2);
%     BW = Wo / Q;
%     [b,a] = iircomb(20 , BW, 'notch'); 
%     ECG_filN = filtfilt(b, a, DATA);

    % 中值滤波消除基线漂移,窗大小默认为采样率的30%
    data_fil_all = medianFilter(data_fil, ceil((Fs*0.3)/2));  
%     ECG_fil_base = medianFilter(data_fil, ceil((Fs*0.3)/2));
elseif strcmp(tag, 'PPG')
    %3阶巴特沃斯[0.8, 3]Hz带通，滤除基线漂移和工频
    order = 3; 
    Fp=0.8; 
    Fn = 3;
    Wp=Fp*2/Fs;
    Wn=Fn*2/Fs;
    [Bb ,Ba]=butter(order,[Wp Wn]);
    data_fil_all=filtfilt(Bb,Ba, DATA); %使用filter的话信号开头幅值较大
end


    
    % 计算ECG横坐标时间
    Rtime = (1:length(data_fil_all)) / Fs;
    
%     %异常值检测与去除
%     [~,R_loc,~,~,~,~] = pan_tompkin(ECG,Fs,0);
%     thresh = 2*median(ECG_fil_all(R_loc));
%     ECGoutliers = threshFilter(ECG_fil_all,'above', thresh);
%     [ECG_fil_allA, ~]=replaceOutliers(Rtime,ECG_fil_all,ECGoutliers,'median',100);

    % R峰检测
    % pan_tompkin方法处理--A
%    ECG_fil_allA(isnan(ECG_fil_allA)) = 0;
    [~,R_loc,~,~,~,~] = pan_tompkin(data_fil_all,Fs,0);
    if isempty(R_loc)
        RtimeR.A = 0;
        Rpeak.A = 0;
        IBI.A(:,1) = 0;
        IBI.A(:,2) = 0;
        IBI_correction.A(:,1) = 0;
        IBI_correction.A(:,2) = 0;
    else
        RtimeR.A = R_loc / Fs;
        IBI.A(:,1) = RtimeR.A(2:end);
        IBI.A(:,2) = diff(RtimeR.A)';

        % 自动校正IBI
        R_loc = autoCorrection(Fs, data_fil_all, R_loc, 'PT');

        RtimeR.A = R_loc / Fs;
        Rpeak.A = data_fil_all(R_loc);
        IBI_correction.A(:,1) = RtimeR.A(2:end);
        IBI_correction.A(:,2) = diff(RtimeR.A)';
    end
    
% 
%         %异常值检测与去除 效果不好
%     R_loc = kota(ECG_fil_all, ECG_fil_base, Fs);
%     thresh = 2*median(ECG_fil_all(R_loc));
%     ECGoutliers = threshFilter(ECG_fil_all,'above', thresh);
%     [ECG_fil_allB, ~]=replaceOutliers(Rtime,ECG_fil_all,ECGoutliers,'median',100);
    % kota方法处理--B
%     ECG_fil_allB(isnan(ECG_fil_allB)) = 0;
    R_loc = kota(data_fil_all, data_fil_all, Fs);
    if isempty(R_loc)
        RtimeR.B = 0;
        Rpeak.B = 0;
        IBI.B(:,1) = 0;
        IBI.B(:,2) = 0;
        IBI_correction.B(:,1) = 0;
        IBI_correction.B(:,2) = 0;
    else
        RtimeR.B = R_loc / Fs;
        IBI.B(:,1) = RtimeR.B(2:end);
        IBI.B(:,2) = diff(RtimeR.B)';

        % 自动校正IBI
        %R_loc = autoCorrection(Fs, ECG_fil_all, R_loc, 'PT');
        R_loc = autoCorrection(Fs, data_fil_all, R_loc, 'kota');
%         [IBI_correction.B, R_loc] = autoCorrection2(R_loc,Fs,ECG_fil_base);
        
        RtimeR.B = R_loc / Fs;
        Rpeak.B = data_fil_all(R_loc);
        IBI_correction.B(:,1) = RtimeR.B(2:end);
        IBI_correction.B(:,2) = diff(RtimeR.B)';
    end


    %% 对检测到的R峰所输出的IBI，进行滤波[针对异常值]+重构
    %nibi,校正后IBI值；art,定位异常值
    if size(IBI_correction.A,1)>2
        [nibi,~]=preProcessIBI(IBI_correction.A, ...
            'locateMethod', IBIvarargin.locateMethod, ...
            'locateInput', IBIvarargin.locateInput, ...
            'replaceMethod', IBIvarargin.replaceMethod, ...
            'replaceInput',IBIvarargin.replaceInput*Fs);
        RtimeR.autoA = nibi(:, 1);
        IBI_correction.autoA = nibi; %t=nibi(:, 1); y=nibi(:, 2);
        Rpeak.autoA = data_fil_all(round(nibi(:, 1)*Fs));
    else
        RtimeR.autoA = [];
        IBI_correction.autoA = []; %t=nibi(:, 1); y=nibi(:, 2);
        Rpeak.autoA = [];
    end

    [nibi,~]=preProcessIBI(IBI_correction.B, ...
        'locateMethod', IBIvarargin.locateMethod, ...
        'locateInput', IBIvarargin.locateInput, ...
        'replaceMethod', IBIvarargin.replaceMethod, ...
        'replaceInput',IBIvarargin.replaceInput*Fs);
     RtimeR.autoB = nibi(:, 1);
     IBI_correction.autoB = nibi;
     Rpeak.autoB = data_fil_all(round(nibi(:, 1)*Fs));
     
     %% 比较Rpeak与RtimeR长度是否相同，若相差较多改用校正IBI前的AB算法结果
    


%     % C方法处理
%     [R_loc,sign,en_thres] = qrs_detect2(ECG_fil_all,0.25,0.6,Fs);
%     if isempty(R_loc)
%         RtimeR.C = 0;
%         Rpeak.C = 0;
%         IBI.C(:,1) = 0;
%         IBI.C(:,2) = 0;
%         IBI_correction.C(:,1) = 0;
%         IBI_correction.C(:,2) = 0;
%     else
%         RtimeR.C = R_loc / Fs;
%         IBI.C(:,1) = RtimeR.C(2:end);
%         IBI.C(:,2) = diff(RtimeR.C)';
% 
%         % 自动校正IBI
%         R_loc = autoCorrection(Fs, ECG_fil_all, R_loc, 'PT');
%         RtimeR.C = R_loc / Fs;
%         Rpeak.C = ECG_fil_all(R_loc);
%         IBI_correction.C(:,1) = RtimeR.C(2:end);
%         IBI_correction.C(:,2) = diff(RtimeR.C)';
%     end
% function [outliers]=threshFilter(s,type,thresh)
%     %threshFilter: Locate outliers based on a threshold
% 
%         n = length(s);
%         % Create a matrix of thresh values by replicating the thresh 
%         % for n rows
%         thresh = repmat(thresh,n,1);
%         % Create a matrix of zeros and ones, where ones indicate the %
%         % location of outliers
%         if strcmp(type,'above')        
%             outliers = s > thresh;
%         elseif strcmp(type,'below')
%             outliers = s < thresh;        
%         end
% end
end