function exportSlideWindowHRV(parameter, newpath, filename, dataInfo)
%% 滑动窗口分析
    
    startTime = parameter.startTime;
    windowTime = parameter.windowTime;
    step = parameter.step;
    IBI = dataInfo.IBI;
    cycle_index = fix((IBI(end,1)-startTime-windowTime)/parameter.step)+1; %滑动分析次数
    
    startTime1 = startTime;
    for i = 1:cycle_index % 滑动窗的循环
        IBI_sample = IBISample(IBI, startTime1, windowTime);
        startTime1 = startTime1 + step;
        [TDoutput, FDoutput, PDoutput, NDoutput] = hrvAnalyse(parameter, IBI_sample, 'corr');
        HRVResults.TDoutput(i) = TDoutput;
        HRVResults.FDoutput(i) = FDoutput;
        HRVResults.PDoutput(i) = PDoutput;
        HRVResults.NDoutput(i) = NDoutput;
    end

    % 进入默认位置
    oldpath = cd;
    if isempty(newpath)
        newpath = cd;
    end
    cd(newpath);

    % 打开选择文件对话框
    [fileName, pathName] = uiputfile([filename '_SlideWindowHRV' '.xlsx'],'保存滑动窗口分析HRV结果');
    
    cd(oldpath);
    
    % 如果未选择文件则直接返回
    if ~fileName
        return;
    else
        str = [pathName fileName]; 
        
        % 保存数据
        writecell(tableSlideWindowHRV(dataInfo, startTime, windowTime, step, HRVResults), char(str));
    end
end

function tableOut = tableSlideWindowHRV(dataInfo, startTime, windowTime, step, HRVResults)
    %% HRV结果表格
    tableOut = [];
    tableOut{1,1}='文件名';tableOut{1,2}=dataInfo.fileName;
    tableOut{2,1}='采样率';tableOut{2,2}=dataInfo.Fs;tableOut{2,3}='Hz';
    tableOut{3,1}='数据时长';tableOut{3,2}=dataInfo.Stime;
    tableOut{4,1}='窗口开始时间';tableOut{4,2}=calcTime(startTime,'time2str');
    tableOut{5,1}='窗口持续时间';tableOut{5,2}=calcTime(windowTime,'time2str');
    tableOut{6,1}='窗口滑动步长';tableOut{6,2}=calcTime(step,'time2str');
    tableOut{7,1}='时间窗口';

    idxR = 8; % HRV结果开始行
    tableOut{idxR,1}='时域结果';
    tableOut{idxR+1,1}='MeanRR (单位:ms)';
    tableOut{idxR+2,1}='SDNN (单位:ms)';
    tableOut{idxR+3,1}='MeanHR (单位:bpm)';
    tableOut{idxR+4,1}='SDHR (单位:bpm)';
    tableOut{idxR+5,1}='RMSSD (单位:ms)';
    tableOut{idxR+6,1}='NNx (单位:count)';
    tableOut{idxR+7,1}='pNNx (单位:%)';
    tableOut{idxR+8,1}='SDNNi (单位:ms)';
    tableOut{idxR+9,1}='HRVti';
    tableOut{idxR+10,1}='TINN (单位:ms)';

    tableOut{idxR+11,1}='频域结果-FFT';
    tableOut{idxR+12,1}='Peak(VLF) (单位:Hz)';
    tableOut{idxR+13,1}='Peak(LF) (单位:Hz)';
    tableOut{idxR+14,1}='Peak(HF) (单位:Hz)';
    tableOut{idxR+15,1}='Power(VLF) (单位:ms²)';
    tableOut{idxR+16,1}='Power(LF) (单位:ms²)';
    tableOut{idxR+17,1}='Power(HF) (单位:ms²)';
    tableOut{idxR+18,1}='Power(VLF) (单位:%)';
    tableOut{idxR+19,1}='Power(LF) (单位:%)';
    tableOut{idxR+20,1}='Power(HF) (单位:%)';
    tableOut{idxR+21,1}='Power(LF) (单位:n.u.)';
    tableOut{idxR+22,1}='Power(HF) (单位:n.u.)';
    tableOut{idxR+23,1}='LF/HF';

    tableOut{idxR+24,1}='频域结果-AR';
    tableOut{idxR+25,1}='Peak(VLF) (单位:Hz)';
    tableOut{idxR+26,1}='Peak(LF) (单位:Hz)';
    tableOut{idxR+27,1}='Peak(HF) (单位:Hz)';
    tableOut{idxR+28,1}='Power(VLF) (单位:ms²)';
    tableOut{idxR+29,1}='Power(LF) (单位:ms²)';
    tableOut{idxR+30,1}='Power(HF) (单位:ms²)';
    tableOut{idxR+31,1}='Power(VLF) (单位:%)';
    tableOut{idxR+32,1}='Power(LF) (单位:%)';
    tableOut{idxR+33,1}='Power(HF) (单位:%)';
    tableOut{idxR+34,1}='Power(LF) (单位:n.u.)';
    tableOut{idxR+35,1}='Power(HF) (单位:n.u.)';
    tableOut{idxR+36,1}='LF/HF';

    tableOut{idxR+37,1}='非线性结果';
    tableOut{idxR+38,1}='SD1 (单位:ms)';
    tableOut{idxR+39,1}='SD2 (单位:ms)';
    tableOut{idxR+40,1}='SD2/SD1';
    tableOut{idxR+41,1}='SampEn';
    tableOut{idxR+42,1}='DFA α';
    tableOut{idxR+43,1}='DFA α1';
    tableOut{idxR+44,1}='DFA α2';
    
    startTime2 = startTime;
    for i = 1 : length(HRVResults.TDoutput)
        timeResult = HRVResults.TDoutput(i);
        welchResult = HRVResults.FDoutput(i).welch.hrv;
        arResult = HRVResults.FDoutput(i).ar.hrv;
        pdResult = HRVResults.PDoutput(i);
        ndResult = HRVResults.NDoutput(i);
        idxC = i+1; % HRV结果所在列

        % 时间窗口
        tableOut{7,idxC} = [calcTime(startTime2,'time2str') '--' calcTime(startTime2+windowTime,'time2str')];
        startTime2 = startTime2 + step;

        % 时域结果
        tableOut{idxR+1,idxC}=timeResult.mean;
        tableOut{idxR+2,idxC}=timeResult.SDNN;
        tableOut{idxR+3,idxC}=timeResult.meanHR;
        tableOut{idxR+4,idxC}=timeResult.sdHR;
        tableOut{idxR+5,idxC}=timeResult.RMSSD;
        tableOut{idxR+6,idxC}=timeResult.NNx;
        tableOut{idxR+7,idxC}=timeResult.pNNx;
        tableOut{idxR+8,idxC}=timeResult.SDNNi;
        tableOut{idxR+9,idxC}=timeResult.HRVTi;
        tableOut{idxR+10,idxC}=timeResult.TINN;
    
        % 频域结果-welch
        tableOut{idxR+12,idxC}=welchResult.peakVLF;
        tableOut{idxR+13,idxC}=welchResult.peakLF;
        tableOut{idxR+14,idxC}=welchResult.peakHF;
        tableOut{idxR+15,idxC}=welchResult.aVLF;
        tableOut{idxR+16,idxC}=welchResult.aLF;
        tableOut{idxR+17,idxC}=welchResult.aHF;
        tableOut{idxR+18,idxC}=welchResult.pVLF;
        tableOut{idxR+19,idxC}=welchResult.pLF;
        tableOut{idxR+20,idxC}=welchResult.pHF;
        tableOut{idxR+21,idxC}=welchResult.nLF;
        tableOut{idxR+22,idxC}=welchResult.nHF;
        tableOut{idxR+23,idxC}=welchResult.LFHF;
        
        % 频域结果-ar
        tableOut{idxR+25,idxC}=arResult.peakVLF;
        tableOut{idxR+26,idxC}=arResult.peakLF;
        tableOut{idxR+27,idxC}=arResult.peakHF;
        tableOut{idxR+28,idxC}=arResult.aVLF;
        tableOut{idxR+29,idxC}=arResult.aLF;
        tableOut{idxR+30,idxC}=arResult.aHF;
        tableOut{idxR+31,idxC}=arResult.pVLF;
        tableOut{idxR+32,idxC}=arResult.pLF;
        tableOut{idxR+33,idxC}=arResult.pHF;
        tableOut{idxR+34,idxC}=arResult.nLF;
        tableOut{idxR+35,idxC}=arResult.nHF;
        tableOut{idxR+36,idxC}=arResult.LFHF;
    
        % 非线性结果
        tableOut{idxR+38,idxC}=pdResult.SD1;
        tableOut{idxR+39,idxC}=pdResult.SD2;
        tableOut{idxR+40,idxC}=pdResult.SDratio;
        tableOut{idxR+41,idxC}=ndResult.sampen(end);
        tableOut{idxR+42,idxC}=ndResult.dfa.alpha(1);
        tableOut{idxR+43,idxC}=ndResult.dfa.alpha1(1);
        tableOut{idxR+44,idxC}=ndResult.dfa.alpha2(1);
    end
end