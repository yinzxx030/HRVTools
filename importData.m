function [newpath, flag, fileName, suffix, Resp, data, Stime] = importData(newpath, Fs, tag)
%% HRV模块中导入数据

    % 进入默认位置
    oldpath = cd;
    if isempty(newpath)
        newpath = cd;
    end
    cd(newpath);

    flag = false;
    suffix = [];
    Resp = [];
    data = []; %ECG或PPG
    Stime = [];

    % 打开选择文件对话框
    [fileName, pathName] = uigetfile({'*.txt';'*.bin';'*.edf';'*.mat';'*.dat'},'Select the ECG file');

    % 记录本次位置
    if fileName ~= 0
        newpath = pathName;
    end
    cd(oldpath);

    % 如果未选择文件则直接返回
    if ~fileName
        return;
    else
        % 文件后缀
        suffix = lower(fileName(end-2:end));

        % 根据文件后缀读取数据
        % 读取txt文件
        if strcmp(suffix, 'txt')
            % 导入数据
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
                    data = inputdata_ori;
                elseif size(inputdata_ori,2) == 3
                    % 读取白色板子数据
                    %数据格式：时间 呼吸 心电
                    % 读取呼吸数据，固定第二列
                    Resp = inputdata_ori(:,2);
                    % 读取心电数据，固定第三列
                    data = inputdata_ori(:,3);
                end

                % 计算实际数据长度时间
                Stime = calcTime(round(length(data)/Fs), 'time2str'); 
                % 文件正确
                flag = true;
                % 文件名称
                fileName = fileName(1:end-4);
            end

        elseif strcmp(suffix, 'bin')
            % 利用帧长分段
            length_frame = 24; %SD卡每帧字节数，按照字节数对数据进行分段后读取各行对应数据；
            
            % 读取.bin文件
            fip=fopen( [file_path,fileName] ,'rb');
            [data,~]=fread(fip); %data输出SD卡中全部数据，用于心电、血氧解析
            SD_label = strfind(data', [170, 221]); %取end 找到SD卡尾帧0xaa, 0xdd位置
            %存储尾帧日期时间
            if isequal(SD_label(end)+19 , length(data))
                date = data(SD_label(end)+2 : SD_label(end)+6, :);
            end
            readfs = data(16);
            %取中间去除首尾帧的有效数据
            data = data(22:SD_label(end)-1, :);
            fclose(fip);
            % 提取采样率，位于SD卡首帧16位
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
    
            % 断帧，通过帧长直接分段
            data_final = reshape(data,length_frame,[]);%幅值较大的数据（全为正值）直接计算，数据为N行1列，分割为20行后，每列为一帧（20字节）
            data_final = data_final(:,2:(end-1));
    
            % 检验分段是否准确【1】帧头是否为0xaa和0xee
            num = length(data_final);
            if ~isequal(data_final(1, :) , 170*ones(1, num)) && ~isequal(data_final(2, :) ,238*ones(1, num))
                msgbox('数据有误','ERROR')
            end
    
            % 读取bin数据
            %按照SD卡存储顺序读取各路信号高低位
            resp_high = dec2hex(data_final(5, :));
            resp_low = dec2hex(data_final(6, :));
            ECG_high = dec2hex(data_final(7, :));
            ECG_low = dec2hex(data_final(8, :));

            % 读取呼吸数据
            Resp = Hex2Dec(data_final(5, :),resp_low, resp_high);
            % 读取心电数据
            data = Hex2Dec(data_final(7, :),ECG_low, ECG_high);
            
            % 文件正确
            flag = true;
            % 计算实际数据长度时间，输出文件名
            Stime = round(num/fs);
            %Stime = calcTime(round(N/Fs), 'time2str');
            fileName = fileName(1:end-4);

            % 读取mat文件
        elseif strcmp(suffix, 'mat')
            % 导入数据
            %inputdata_ori = load([pathName fileName]);
            inputdata_ori = load([pathName fileName]).eegdata;

            % 检查数据列数是否正确
            if size(inputdata_ori,1) ~= 19
                % 文件不正确
                msgbox("输入数据格式不正确")
                return;
            else
                data = -inputdata_ori(12,:)';

                % 计算实际数据长度时间
                Stime = calcTime(round(length(data)/Fs), 'time2str'); 
                % 文件正确
                flag = true;
                % 文件名称
                fileName = fileName(1:end-4);
            end

        % 读取dat文件，MIT/BIH数据库格式
        elseif strcmp(suffix, 'dat')
            SAMPLES2READ = Fs*60*30; % 指定需要读入的采样点数
                                    % 若.dat文件中存储有两个通道的信号:
                                    % 则读入 2*SAMPLES2READ 个数据
                                    % MIT采样率为360Hz，默认截取30分钟
            % 导入数据
            [~, data] = importMITData(pathName, fileName, SAMPLES2READ, 1);

            % 计算实际数据长度时间
            Stime = calcTime(round(length(data)/Fs), 'time2str'); 
            % 文件正确
            flag = true;
            % 文件名称
            fileName = fileName(1:end-4);
        elseif strcmp(suffix, 'edf')
            %读取数据
            readName = [pathName, '\', fileName];
            [L, edfb] = edfread(readName);
        if strcmp(tag, 'ECG')
            row =  find( ismember(L.label,'ECG'));
        elseif strcmp(tag, 'PPG')
            row =  find( ismember(L.label,'Infrared'));
        end
        if isempty(row)
            msgbox('文件中不含所选数据')
        else
        %导入数据
        inputdata_ori = edfb(row, : )'; 
        end
        data = inputdata_ori;
   
            %计算时间
            Stime = calcTime(round(length(ECG)/Fs), 'time2str');
            % 文件正确
                flag = true;
                % 文件名称
                fileName = fileName(1:end-4);
        else
            % 文件后缀不正确
            msgbox("输入数据格式不正确")
            return; 
        end
    end  
end

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