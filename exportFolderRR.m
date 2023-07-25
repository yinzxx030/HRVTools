function exportFolderRR(parameter, nameList, RDetectmethod)
%% 保存RR结果

    startTime = parameter.startTime;
    windowTime = parameter.windowTime;
    Fs = parameter.Fs;

    pathNameFirst = nameList{1};
    tempFirst = strsplit(pathNameFirst,'\');
    fileNameFirst =  cell2mat(tempFirst(end));
    suffixFirst = fileNameFirst(end-2:end);
    
    if strncmpi(suffixFirst, 'txt', length(suffixFirst))
        for i=1:length(nameList)
            pathName = nameList{i};
            temp = strsplit(pathName,'\');
            fileName =  cell2mat(temp(end));
            
            % 导入数据
            inputdata_ori = importdata(pathName);
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
                    ECG_ori = inputdata_ori;
                elseif size(inputdata_ori,2) == 3
                    % 读取白色板子数据
                    %数据格式：时间 呼吸 心电
                    % 读取心电数据，固定第三列
                    ECG_ori = inputdata_ori(:,3);
                end
                
                processAndSaveRR(pathName, fileName, ECG_ori, Fs, RDetectmethod, startTime, windowTime)
            end
        end
    elseif strncmpi(suffixFirst, 'mat', length(suffixFirst))
        for i=1:length(nameList)
            pathName = nameList{i};
            temp = strsplit(pathName,'\');
            fileName =  cell2mat(temp(end));
            
            % 导入数据
            inputdata_ori = load(pathName).b;
    
            % 检查数据列数是否正确
            if size(inputdata_ori,1) ~= 19
                % 文件不正确
                msgbox("输入数据格式不正确")
                return;
            else
                ECG_ori = -inputdata_ori(12,:)';
            end

            processAndSaveRR(pathName, fileName, ECG_ori, Fs, RDetectmethod, startTime, windowTime)
        end
    elseif strncmpi(suffixFirst, 'dat', length(suffixFirst))
        for i=1:length(nameList)
            pathName = nameList{i};
            temp = strsplit(pathName,'\');
            pathName = pathName(1:end-length(temp{end}));
            fileName = cell2mat(temp(end));
            
            % 导入数据
            SAMPLES2READ = 648000; % 指定需要读入的采样点数
                                    % 若.dat文件中存储有两个通道的信号:
                                    % 则读入 2*SAMPLES2READ 个数据
                                    % MIT采样率为360Hz，默认截取30分钟
            % 导入数据
            [~, ECG_ori] = importMITData(pathName, fileName, SAMPLES2READ, 1);

            processAndSaveRR(pathName, fileName, ECG_ori, Fs, RDetectmethod, startTime, windowTime)
        end
    end

end

function processAndSaveRR(pathName, fileName, ECG_ori, Fs, RDetectmethod, startTime, windowTime)
    %% HRV结果
    [Rtime, ~, ~, ~, ~, IBI_correction] = preProcessWithOneMethod(ECG_ori, Fs, RDetectmethod);
            
    % 检查分析窗口是否在数据范围内
    if startTime+windowTime <= Rtime(end)
        IBI = IBISample(IBI_correction, startTime, windowTime);
    elseif windowTime > Rtime(end)
        IBI = IBI_correction;
    elseif startTime+windowTime > Rtime(end) && startTime < Rtime(end)
        IBI = IBISample(IBI_correction, Rtime(end)-windowTime, Rtime(end));
    end 
    
    % 文件名
    str = [pathName fileName(1:end-4) '_RR.xlsx'];

    % 列名称
    title={'RtimeR','RR'};
    result_table = table(IBI(:,1),roundn(IBI(:,2), -3),'VariableNames',title);
    
    % 保存数据
    writetable(result_table, char(str));
end