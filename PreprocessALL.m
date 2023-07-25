function varargout = PreprocessALL(varagin)
Fs = varagin{1};
ECG = varagin{2};
if nargin==8
    %对个体化迷走原始bin文件6导（7个）ECG, EEG1, EEG2, PPG_inr, PPG_r, EDA, RES,信号进行默认滤波处理
    EEG1 = varagin{3};
    EEG2 = varagin{4};
    PPG_inr = varagin{5};
    PPG_r = varagin{6};
    EDA = varagin{7};
    RES = varagin{8};
elseif nargin == 4
    EEG_PPG = varagin{3};
    RES = varagin{4};
end
    %% 心电：
    % 中值滤波消除基线漂移,窗大小默认为采样率的30%
    ECG_fil_base = medianFilter(ECG, ceil((Fs*0.3)/2));
    % 小波变换去除工频噪声
    if Fs == 500
        [c,l] = wavedec(ECG_fil_base,3,'db6');
        ECG_fil = wrcoef('a',c,l,'db6',3);
    elseif Fs ==1000
        [c,l] = wavedec(ECG_fil_base,4,'db6');
        ECG_fil = wrcoef('a',c,l,'db6',4);
    elseif Fs ==100
        [c,l] = wavedec(ECG_fil_base,1,'db6');
        ECG_fil = wrcoef('a',c,l,'db6',1);
    elseif Fs ==200
        [c,l] = wavedec(ECG_fil_base,2,'db6');
        ECG_fil = wrcoef('a',c,l,'db6',2);
    end
    varargout{1} = ECG_fil;
    %% 脑电
    SB=[4.5 35]/Fs*2; % 带通，滤除其他干扰
    [Bb,Ab]=butter(4,SB,'bandpass');
    try
        EEG1_fil=filtfilt(Bb,Ab,EEG1);
        EEG2_fil=filtfilt(Bb,Ab,EEG2);
        varargout{2} = EEG1_fil;
        varargout{3} = EEG2_fil;
    catch
        struct = ['O1', 'C3', 'F3', 'F4', 'C4', 'O2', 'M2', 'E1', 'E2'];
        for i = 1:9
            EEG = getfield(EEG_PPG, struct(i)); %#ok<GFLD> 
            varargout{i+1} = filtfilt(Bb,Ab,EEG); %#ok<AGROW> 
        end
    end
    %% 血氧
    SBPPG=[0.8 3]/Fs*2; % 带通
    [Bt,At]=butter(3,SBPPG,'bandpass');
    try
        PPG_fil_r=filtfilt(Bt,At,PPG_r);
        PPG_fil_inr=filtfilt(Bt,At,PPG_inr); 
        varargout{4} = PPG_fil_r;
        varargout{5} = PPG_fil_inr;
    catch
        varargout{11} = filtfilt(Bt,At, EEG_PPG.PPG_inr);
    end
    %% 皮电+呼吸
    Me=100;               %滤波器阶数
    L=100;                %窗口长度
    beta=100;             %衰减系数
    wc1=49/Fs*pi;     %wc1为高通滤波器截止频率，对应51Hz
    wc2=51/Fs*pi     ;%wc2为低通滤波器截止频率，对应49Hz
    h=ideal_lp(0.132*pi,Me)-ideal_lp(wc1,Me)+ideal_lp(wc2,Me); %h为陷波器冲击响应
    w=kaiser(L,beta);
    y=h.*rot90(w);         %y为50Hz陷波器冲击响应序列
    try
        edafil = filtfilt(y,1,EDA);
        EDA_fil = smooth(edafil,500);
        respfil = filtfilt(y,1,RES);
        RES_fil = smooth(respfil,250);
        varargout{6} = EDA_fil;
        varargout{7} = RES_fil;
    catch
        respfil = filtfilt(y,1,RES);
        varargout{12} = smooth(respfil,250);
    end
end