function [file_path, flag, fileName,suffix, fs, ECG, bin, edf, RES, Stime] = importFirstDATA(file_path)
%函数功能：读取并导入.bin文件，该函数中其他文件格式读取时采样率未知！
%INPUT:
%file_path：数据所在路径
%OUTPUT:
%共输出7路信号：ECG、EEG1、EEG2、PPG(红光、红外光)、呼吸、EDA(皮电)
%后续信号处理仅使用PPG红外光


%% 第一步选择通道中导入数据

% 进入默认位置
oldpath = cd;
if isempty(file_path)
    file_path = cd;
end
cd(file_path);

fs = [];
ECG = [];
bin = {};
edf = {};
RES = [];
Stime = [];


% 打开选择文件对话框,只有bin文件含有多路信号，其他格式均为心电信号（或加一导呼吸）
[fileName, pathName] = uigetfile({'*.edf';'*.bin';'*.txt';'*.mat';'*.dat'},'Select the file');

% 记录本次位置
if fileName ~= 0
    file_path = pathName;
end
cd(oldpath);
% 如果未选择文件则直接返回
if ~fileName
    return;
else
    % 文件后缀
    suffix = fileName(end-2:end);
    if strcmp(suffix, 'bin')
        %% 利用帧长分段
        length_frame = 24; %SD卡每帧字节数，按照字节数对数据进行分段后读取各行对应数据；
        %% 读取.bin文件
        fip=fopen( [file_path,fileName] ,'rb');
        [data,~]=fread(fip); %data输出SD卡中全部数据，用于心电、血氧解析
        SD_label = strfind(data', [170, 238]); %取end 找到SD卡尾帧0xaa, 0xdd位置
        %存储尾帧日期时间
        if isequal(SD_label(end)+19 , length(data))
            date = data(SD_label(end)+2 : SD_label(end)+6, :);
        end
        readfs = data(16);
        %取中间去除首尾帧的有效数据
        data = data(22:SD_label(end)-1, :);
        fclose(fip);
        %% 提取采样率，位于SD卡首帧16位
        switch readfs
            case 0
                fs = 125;
            case 1
                fs = 250;
            case 2
                fs = 500;
            case 3
                fs = 1000;
        end

        %% 断帧，通过帧长直接分段
        data_final = reshape(data,length_frame,[]);%幅值较大的数据（全为正值）直接计算，数据为N行1列，分割为20行后，每列为一帧（20字节）
        data_final = data_final(:,2:(end-1));

        %% 检验分段是否准确【1】帧头是否为0xaa和0xee
        num = length(data_final);
        if ~isequal(data_final(1, :) , 170*ones(1, num)) && ~isequal(data_final(2, :) ,238*ones(1, num))
            msgbox('数据有误','ERROR')
        end

        %% 读取数据
        %按照SD卡存储顺序读取各路信号高低位
        resp_high = dec2hex(data_final(5, :));
        resp_low = dec2hex(data_final(6, :));
        ECG_high = dec2hex(data_final(7, :));
        ECG_low = dec2hex(data_final(8, :));
        EEG1_high = dec2hex(data_final(9, :));
        EEG1_low= dec2hex(data_final(10, :));
        EEG2_high = dec2hex(data_final(11, :));
        EEG2_low = dec2hex(data_final(12, :));
        PPGr_high = dec2hex(data_final(13, :));
        PPGr_low = dec2hex(data_final(14, :));
        PPGinr_high = dec2hex(data_final(15, :));
        PPGinr_low = dec2hex(data_final(16, :));
        EDA_high = dec2hex(data_final(17, :));
        EDA_low = dec2hex(data_final(18, :));

        % 读取呼吸数据
        RES = Hex2Dec(data_final(5, :),resp_low, resp_high);
        % 读取心电数据
        ECG = Hex2Dec(data_final(7, :),ECG_low, ECG_high);
        % 读取脑电数据
        bin.EEG1=  Hex2Dec(data_final(9, :),EEG1_low, EEG1_high);
        bin.EEG2 =  Hex2Dec(data_final(11, :),EEG2_low, EEG2_high);
        % 读取PPG红光、红外光数据
        bin.PPG_r = Hex2Dec(data_final(13, :), PPGr_low, PPGr_high);
        bin.PPG_inr = Hex2Dec(data_final(15, :), PPGinr_low, PPGinr_high);
        % 读取皮电数据
        bin.EDA = Hex2Dec(data_final(17, :), EDA_low, EDA_high);
        % 文件正确
        flag = true;
        % 计算实际数据长度时间，输出文件名
%         Stime = round(num/fs);
        Stime = calcTime(round(num/fs), 'time2str');
        fileName = fileName(1:end-4);

    elseif strcmp(suffix, 'txt') || strcmp(suffix, 'TXT')
        inputdata_ori = importdata([pathName fileName]);
        % 检查数据列数是否正确
        if size(inputdata_ori,2) ~= 3 && size(inputdata_ori,2) ~= 1
            % 文件不正确
            msgbox("输入数据格式不正确")
            return;
        else
            % 去除最后一行不完整数据
            inputdata_ori = inputdata_ori(1:end-1,:);

            if size(inputdata_ori,2) == 1
                % 读取心电数据
                %数据格式：心电
                % 读取心电数据，固定第一列
                ECG = inputdata_ori;
            elseif size(inputdata_ori,2) == 3
                % 读取白色板子数据
                %数据格式：时间 呼吸 心电
                % 读取呼吸数据，固定第二列
                RES = inputdata_ori(:,2);
                % 读取心电数据，固定第三列
                ECG = inputdata_ori(:,3);
            end
            % 计算实际数据长度时间
            fs = 500; %目前默认白板子采样率为500Hz
            Stime = calcTime(round(length(ECG)/fs), 'time2str');

            % 文件正确
            flag = true;
            % 文件名称
            fileName = fileName(1:end-4);
        end
        % 读取dat文件，MIT/BIH数据库格式
    elseif strcmp(suffix, 'dat')
        Fs=360;
        SAMPLES2READ = Fs*60*30; % 指定需要读入的采样点数
        % 若.dat文件中存储有两个通道的信号:
        % 则读入 2*SAMPLES2READ 个数据
        % MIT采样率为360Hz，默认截取30分钟
        % 导入数据
        [~, ECG] = importMITData(pathName, fileName, SAMPLES2READ, 1);

        % 计算实际数据长度时间
        Stime = calcTime(round(length(ECG)/Fs), 'time2str');
        % 文件正确
        flag = true;
        % 文件名称
        fileName = fileName(1:end-4);

    elseif strcmp(suffix, 'edf')
        %读取数据,当前edf只读取心电数据
        readName = [pathName, '\', fileName];
        [L, edfb] = edfread(readName);
        Label_all = {'O1', 'C3', 'F3', 'F4', 'C4', 'O2', 'M2', 'E1', 'E2', 'ECG', 'Benihikari', 'Infrared', 'THOR'};
        %PSG白天采集软件标签：9导脑电、心电、PPG红光、红外光、呼吸信号
        rowlabel =  find( ismember(Label_all, L.label));
        EDF = zeros(13, length(edfb));
        %导入数据 % 按对应通道位置存出edf中数据
        j= 0;
        for n = 1:13
            if ismember(n, rowlabel)
                j = j+1;
                EDF(n, :) = edfb(j, : );
            end
        end

 
%         edf = setfield(edf,'O1',EDF(1, :), 'C3', EDF(2, :), 'F3', EDF(3, :), 'F4', EDF(4, :), 'C4', EDF(5, :), 'O2', EDF(6, :), ...
%             'M2', EDF(7, :), 'E1', EDF(8, :), 'E2', EDF(9, :), 'PPG_inr',EDF(12, :));
        ECG = EDF(10, :);
        RES = EDF(13, :) ;
        %计算时间
        Fs = 1000; %PSG设备采样率
        Stime = calcTime(round(length(ECG)/Fs), 'time2str');
        % 文件正确
        flag = true;
        % 文件名称
        fileName = fileName(1:end-4);

    else
        msgbox("输入数据格式不正确")
        return;
    end
end

%% 将两个字节的数据 小端模式转化为十进制
%symbol 符号位：提取高字节，判断最高位是0-正数，1-负数
%low_bit 低字节的数据
%high bit 高字节的数据
%eg:FD E5--> -538 data 返回转为10进制的数据
    function data = Hex2Dec(symbol,low_bit, high_bit)
        data_high_low = strcat(high_bit, low_bit);
        for i = 1:length(symbol)
            if(symbol(i) > 127) % 最高位为1， 负数
                data(i,:) = -(hex2dec('FFFF') - hex2dec(data_high_low(i, :)));
            else % 正数不需要处理
                data(i,:) = hex2dec(data_high_low(i, :));
            end
        end
    end

end