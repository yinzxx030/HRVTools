function [newpath, flag, nameList, fileName, ECG, Stime] = importFolder(newpath, Fs)
%% 导入多个数据

    % 进入默认位置
    oldpath = cd;
    if isempty(newpath)
        newpath = cd;
    end
    cd(newpath);

    flag = false;
    ECG = [];
    Stime = [];
    nameList = {};

    % 打开选择文件对话框
    [fileName, pathName] = uigetfile({'*.txt';'*.mat';'*.dat'},'Select the ECG file');
    % 如果未选择文件则直接返回
    if ~fileName
        return;
    else
        str = split(fileName,'.');
        suffix = cell2mat(str(2));
        folder = [pathName, '*.', suffix];
        folderInfo = dir(folder);
        for i=1:length(folderInfo)
            nameList{i,1} = [pathName folderInfo(i).name];
        end
       
        % 记录本次位置
        if fileName ~= 0
            newpath = pathName;
        end
        cd(oldpath);
    
        if strncmpi(suffix, 'txt', length(suffix))
            % 导入数据
            inputdata_ori = importdata([pathName fileName]);
            % 检查数据列数是否正确
            if size(inputdata_ori,2) ~= 3 && size(inputdata_ori,2) ~= 1
                % 文件不正确
                msgbox("输入数据格式不正确")
                return;
            else
                % 数据格式正确
                % 文件正确
                flag = true;
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
                    % 读取心电数据，固定第三列
                    ECG = inputdata_ori(:,3);
                end        
            end
        elseif strncmpi(suffix, 'mat', length(suffix))
            % 导入数据
            inputdata_ori = load([pathName fileName]).b;
            % 检查数据列数是否正确
            if size(inputdata_ori,1) ~= 19
                % 文件不正确
                msgbox("输入数据格式不正确")
                return;
            else
                % 文件正确
                flag = true;
                ECG = -inputdata_ori(12,:)';
            end
        % 读取dat文件，MIT/BIH数据库格式
        elseif strcmp(suffix, 'dat')
            SAMPLES2READ = Fs*60*30; % 指定需要读入的采样点数
                                    % 若.dat文件中存储有两个通道的信号:
                                    % 则读入 2*SAMPLES2READ 个数据
                                    % MIT采样率为360Hz，默认截取30分钟
            % 导入数据
            [~, ECG] = importMITData(pathName, fileName, SAMPLES2READ, 1);
            % 文件正确
            flag = true;
        else
            msgbox('文件格式不正确')
            return;
        end
    end 

    % 计算实际数据长度时间
    Stime = calcTime(length(ECG) / Fs, 'time2str'); 
    % 文件名称
    fileName = fileName(1:end-4);

end