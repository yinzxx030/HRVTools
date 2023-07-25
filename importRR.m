function [newpath, flag, RtimeR, Rpeak, IBI] = importRR(newpath, Fs, ECG)
%% 导入RR数据

    % 进入默认位置
    oldpath = cd;
    if isempty(newpath)
        newpath = cd;
    end
    cd(newpath);

    % 打开选择文件对话框
    [fileName, pathName] = uigetfile({'*.csv';'*.xlsx';'*.mat';'*.atr'},'Select the RR file');
    
    % 记录本次位置
    if fileName ~= 0
        newpath = pathName;
    end
    cd(oldpath);
    
    % 如果未选择文件则直接返回
    if ~fileName
        % 文件是否正确
        flag = false;
        RtimeR = [];
        Rpeak = [];
        IBI = [];
        return;
    else
        % 文件后缀
        suffix = lower(fileName(end-3:end));

        % 根据文件后缀读取数据
        % 读取txt文件
        if strcmp(suffix, 'xlsx')
            % 读取本软件保存的RR文件，有2列
            inputdata = readmatrix([pathName fileName]);
            RtimeR = inputdata(2:end,1);
            Rpeak = ECG(round(RtimeR*Fs));
            IBI(:,1) = RtimeR;
            IBI(:,2) = inputdata(2:end,2);

            flag = true;
        elseif strcmp(suffix, '.csv')
            % 读取PPG输出的csv文件，有2列
            inputdata = readmatrix([pathName fileName]);
            RtimeR = inputdata(2:end,1)/Fs;
            Rpeak = ECG(round(RtimeR*Fs)); %第一列是点数
            IBI(:,1) = RtimeR;
            IBI(:,2) = inputdata(2:end,2);

            flag = true;
        elseif strcmp(suffix, '.mat')
            % 读取kubios保存的RR文件，mat格式
            inputdata = load([pathName fileName]);
            IBI(:,1) = inputdata.Res.HRV.Data.T_RRs{1,1};
            IBI(:,2) = inputdata.Res.HRV.Data.RRs{1,1};
            RtimeR = IBI(:,1);
            Rpeak = ECG(round(RtimeR*Fs));

            flag = true;
        elseif strcmp(suffix, '.atr')
            % 读取MIT数据库注释文件
            sfreq = Fs;
            SAMPLES2READ = sfreq*60*30; % 指定需要读入的采样点数
                                    % 若.dat文件中存储有两个通道的信号:
                                    % 则读入 2*SAMPLES2READ 个数据
                                    % MIT采样率为360Hz，默认截取30分钟
            TIME=(0:(SAMPLES2READ-1)) / sfreq;
            inputdata = loadMITAtr(pathName, fileName, sfreq, TIME);

            RtimeR = inputdata;
            Rpeak = ECG(round(RtimeR*Fs));
            IBI(:,1) = RtimeR(2:end);
            IBI(:,2) = diff(RtimeR);

            flag = true;
        else
            % 文件格式不对
            flag = false;
            msgbox("输入数据格式不正确")
            return;
        end
    end
end

function ATRTIMED = loadMITAtr(pathName, fileName, sfreq, TIME)
%% 加载MIT注释文件
    atrd = fullfile(pathName, fileName); % attribute file with annotation data
    fid3 = fopen(atrd,'r');
    A = fread(fid3, [2, inf], 'uint8')';
    fclose(fid3);
    ATRTIME = [];
    ANNOT = [];
    sa = size(A);
    saa = sa(1);
    i = 1;
    while i <= saa
        annoth = bitshift(A(i,2),-2);
        if annoth == 59
            ANNOT = [ANNOT; bitshift(A(i+3,2),-2)];
            ATRTIME =[ATRTIME;A(i+2,1) + bitshift(A(i+2,2),8)+...
                bitshift(A(i+1,1),16) + bitshift(A(i+1,2),24)];
            i=i+3;
        elseif annoth == 60
            % nothing to do!
        elseif annoth == 61
            % nothing to do!
        elseif annoth == 62
            % nothing to do!
        elseif annoth == 63
            hilfe = bitshift(bitand(A(i,2),3),8) + A(i,1);
            hilfe = hilfe + mod(hilfe, 2);
            i = i + hilfe / 2;
        else
            ATRTIME = [ATRTIME; bitshift(bitand(A(i,2),3),8) + A(i,1)];
            ANNOT = [ANNOT; bitshift(A(i,2),-2)];
        end
        i=i+1;
    end
    ANNOT(length(ANNOT)) = []; % last line = EOF (=0)
    ATRTIME(length(ATRTIME)) = []; % last line = EOF
    clear A;
    ATRTIME = (cumsum(ATRTIME))/sfreq;
    ind = find(ATRTIME <= TIME(end));
    ATRTIMED = ATRTIME(ind);
    ATRTIMED = ATRTIMED(2:end);
    ANNOT = round(ANNOT);
    ANNOTD = ANNOT(ind);
end