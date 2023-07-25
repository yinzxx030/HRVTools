function SQI = calculateSQI(ECG_fil, fs, IBI_correction, R_loc)
%input:
%ECG_fil：预处理后心电信号
%IBI_correction：自动校正后IBI
%R_loc：A/B算法检测到的R峰位置
    SQI = [];
    %% 提取1min数据波形作为模板(单位为点数),窗长取所有RR间隔中值
    if length(ECG_fil)>90*fs
    
    template_win = round(median(IBI_correction(:, 2))*fs); 
    
    if mod(template_win,2)==0
        waveforms = zeros(1, template_win+1);
        halfwindow = template_win/2;
        ECG_single = zeros(length(R_loc)-2 , template_win+1);
    else
        waveforms = zeros(1, template_win);
        halfwindow = (template_win-1)/2;
        ECG_single = zeros(length(R_loc)-2 , template_win);
    end
    %提取模板
    temR_loc = R_loc(30*fs<R_loc&R_loc<90*fs); %取30s~90s数据（/点数）
    
    for p = 2 : length(R_loc)-1
        %记录整段数据单个心跳波形
        ECG_single(p-1 , :) = ECG_fil(R_loc(p)-halfwindow : R_loc(p)+halfwindow, 1)';
        %仅提取在30~90范围内(索引)波形累加
        if dsearchn(R_loc,30*fs)<p && p <dsearchn(R_loc,90*fs)
        waveforms = waveforms + ECG_single(p-1, : );
        end
    end
    %累加后求平均得到模板
    templateRpeak = waveforms/length(temR_loc);
    
    %% 设置阈值评估每次心跳波形的SQI，10s求出一个平均SQI
    % 计算ECG横坐标时间
    Rtime = (1:length(ECG_fil)) / fs;
    RtimeR = R_loc/fs;
    nSQI = fix((Rtime(end)-1)/9); %有多少段10s数据
    for n = 1:nSQI
        left_edge = dsearchn(RtimeR, (n-1)*9); %每段10s数据的时间边界（/索引数）
        right_edge = dsearchn(RtimeR, 9*n+1);
        R_locn = length(R_loc(left_edge+1 : right_edge-1)); %该10s区间内R峰个数
        rSQI = [];
        for r = 1:R_locn
            rSQI(r) = corr(ECG_single(left_edge+r-1 , : )', templateRpeak');
        end
        
        SQI(n, 1) = mean(rSQI);
        SQI(n, 2) = mean(IBI_correction(left_edge+1 : right_edge-1,2))<3; %第二列为判断是否IBI<3的逻辑值
        HR = IBI_correction(left_edge+1 : right_edge-1,2)*60;
        HRlogical = (40<HR & HR<160); %若心率在正常范围内，逻辑值全为1,%%可能有问题！
        SQI(n, 3) = all(HRlogical); 
    end
%     SQI(isnan(SQI(:,1)),:)=[];

    else %数据小于90s的话返回SQI为空
    end
end