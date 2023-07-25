function [stage, tableOut] = segmentSleepData(parameter, ECG, SleepTag)
%% 根据阶段标签分段睡眠数据

    % 分阶段进行心电数据截取
    stage = stageSample(parameter, ECG, SleepTag);

    tableOut = tableStage(stage);
end

function stage = stageSample(parameter, ECG, SleepTag)
%% 分阶段进行IBI截取
    Fs = parameter.Fs;
    totalLength = length(ECG); % 总数据长度
    stageThreshold = parameter.stageThreshold*Fs; % 睡眠阶段长度阈值

    idxS = 1; % 连续阶段开始
    idxE = idxS; % 连续阶段结束

    tagLength = length(SleepTag); % 标签数据长度
    tag = SleepTag(idxS); % 初始标签

    stage = {};
    stage.timeAll = 0;
    idx = 1;

    % 分阶段进行心电数据截取
    while idxE <= tagLength && idxE <= totalLength
        if SleepTag(idxE) ~= tag || idxE == tagLength || idxE == totalLength

            % 按时间顺序存储
            stage.number{idx} = num2str(idx); % 阶段序号
            stage.tag{idx} = labelConvert(tag); % 阶段名称
            stage.ECG{idx} = ECG(idxS: idxE-1); % 阶段ECG
            stage.time(idx) = round((idxE-1-idxS)/Fs); % 阶段时长（秒数）
            stage.timeMinute(idx) = roundn((idxE-1-idxS)/Fs/60, -1); % 阶段时长（分钟）
            stage.timeStr{idx} = calcTime(stage.time(idx),'time2str'); % 阶段时长（字符串）
            stage.startTimeStr{idx} = calcTime(idxS/Fs,'time2str'); % 阶段开始时间（字符串）
            stage.endTimeStr{idx} = calcTime((idxE-1)/Fs,'time2str'); % 阶段结束时间（字符串）
            stage.startIdx(idx) = idxS; % 阶段开始索引
            stage.endIdx(idx) = idxE-1; % 阶段结束索引
            stage.tStE(idx,1) = round(idxS/totalLength*100); % 阶段开始时间占比
            stage.tStE(idx,2) = round((idxE-1)/totalLength*100); % 阶段结束时间占比
            stage.timeAll = stage.timeAll + stage.time(idx); % 数据总长度
            stage.ifHRV{idx} = ' '; % 片段是否进行过HRV分析，初始为空值
            stage.anaTimeStr{idx} = '00:00:00'; % 阶段分析时长
            stage.sTFlag(idx) = false;

            % 检查连续阶段是否大于最短长度阈值
            if idxE-1-idxS >= stageThreshold
                stage.sTFlag(idx) = true; % 阶段长度大于阈值则为正
            end

            idxS = idxE;
            tag = SleepTag(idxE);
            idx = idx + 1;
        end
        idxE = idxE + 1;
    end
end

function tableOut = tableStage(stage)
%% 阶段数据表格

    tableOut = [];

    idxC1 = 1; % 序号所在列
    idxC2 = 2; % 阶段所在列
    idxC3 = 3; % 时长所在列
    idxC4 = 4; % 开始时间所在列
    idxC5 = 5; % 结束时间所在列
    idxC6 = 6; % 是否进行过HRV分析所在列

    for i = 1 : length(stage.number)
        tableOut{i,idxC1} = stage.number{i}; % 阶段序号
        tableOut{i,idxC2} = stage.tag{i}; % 阶段标签
        tableOut{i,idxC3} = stage.timeMinute(i); % 阶段时长（分钟）
        tableOut{i,idxC4} = stage.startTimeStr{i}; % 阶段开始时间
        tableOut{i,idxC5} = stage.endTimeStr{i}; % 阶段结束时间
        tableOut{i,idxC6} = stage.ifHRV{i}; % 阶段是否进行过HRV分析
    end
end