function tableOut = tableHRV(dataInfo, startTime, windowTime)
%% HRV结果表格

    tableOut = [];
    tableOut{1,1}='文件名';tableOut{1,2}=dataInfo.fileName;
    tableOut{2,1}='采样率';tableOut{2,2}=dataInfo.Fs;tableOut{2,3}='Hz';
    tableOut{3,1}='数据时长';tableOut{3,2}=dataInfo.Stime;
    tableOut{4,1}='分析时长';tableOut{4,2}=[calcTime(startTime,'time2str') '--' calcTime(startTime+windowTime,'time2str')];
    
    idxP = 5; % HRV结果开始行
    tableOut{idxP,1}='时域结果';
    timeResult = dataInfo.TDoutput;
    tableOut{idxP+1,1}='MeanRR';tableOut{idxP+1,2}=timeResult.mean;tableOut{idxP+1,3}='ms';
    tableOut{idxP+2,1}='SDNN';tableOut{idxP+2,2}=timeResult.SDNN;tableOut{idxP+2,3}='ms';
    tableOut{idxP+3,1}='MeanHR';tableOut{idxP+3,2}=timeResult.meanHR;tableOut{idxP+3,3}='bpm';
    tableOut{idxP+4,1}='SDHR';tableOut{idxP+4,2}=timeResult.sdHR;tableOut{idxP+4,3}='bpm';
    tableOut{idxP+5,1}='RMSSD';tableOut{idxP+5,2}=timeResult.RMSSD;tableOut{idxP+5,3}='ms';
    tableOut{idxP+6,1}='NNx';tableOut{idxP+6,2}=timeResult.NNx;tableOut{idxP+6,3}='count';
    tableOut{idxP+7,1}='pNNx';tableOut{idxP+7,2}=timeResult.pNNx;tableOut{idxP+7,3}='%';
    tableOut{idxP+8,1}='SDNNi';tableOut{idxP+8,2}=timeResult.SDNNi;tableOut{idxP+8,3}='ms';
    tableOut{idxP+9,1}='HRVti';tableOut{idxP+9,2}=timeResult.HRVTi;
    tableOut{idxP+10,1}='TINN';tableOut{idxP+10,2}=timeResult.TINN;tableOut{idxP+10,3}='ms';

    tableOut{idxP+11,1}='频域结果-FFT';
    welchResult = dataInfo.FDoutput.welch.hrv;
    tableOut{idxP+12,1}='Peak(VLF)';tableOut{idxP+12,2}=welchResult.peakVLF;tableOut{idxP+12,3}='Hz';
    tableOut{idxP+13,1}='Peak(LF)';tableOut{idxP+13,2}=welchResult.peakLF;tableOut{idxP+13,3}='Hz';
    tableOut{idxP+14,1}='Peak(HF)';tableOut{idxP+14,2}=welchResult.peakHF;tableOut{idxP+14,3}='Hz';
    tableOut{idxP+15,1}='Power(VLF)';tableOut{idxP+15,2}=welchResult.aVLF;tableOut{idxP+15,3}='ms²';
    tableOut{idxP+16,1}='Power(LF)';tableOut{idxP+16,2}=welchResult.aLF;tableOut{idxP+16,3}='ms²';
    tableOut{idxP+17,1}='Power(HF)';tableOut{idxP+17,2}=welchResult.aHF;tableOut{idxP+17,3}='ms²';
    tableOut{idxP+18,1}='Power(VLF)';tableOut{idxP+18,2}=welchResult.pVLF;tableOut{idxP+18,3}='%';
    tableOut{idxP+19,1}='Power(LF)';tableOut{idxP+19,2}=welchResult.pLF;tableOut{idxP+19,3}='%';
    tableOut{idxP+20,1}='Power(HF)';tableOut{idxP+20,2}=welchResult.pHF;tableOut{idxP+20,3}='%';
    tableOut{idxP+21,1}='Power(LF)';tableOut{idxP+21,2}=welchResult.nLF;tableOut{idxP+21,3}='n.u.';
    tableOut{idxP+22,1}='Power(HF)';tableOut{idxP+22,2}=welchResult.nHF;tableOut{idxP+22,3}='n.u.';
    tableOut{idxP+23,1}='LF/HF';tableOut{idxP+23,2}=welchResult.LFHF;

    tableOut{idxP+24,1}='频域结果-AR';
    arResult = dataInfo.FDoutput.ar.hrv;
    tableOut{idxP+25,1}='Peak(VLF)';tableOut{idxP+25,2}=arResult.peakVLF;tableOut{idxP+25,3}='Hz';
    tableOut{idxP+26,1}='Peak(LF)';tableOut{idxP+26,2}=arResult.peakLF;tableOut{idxP+26,3}='Hz';
    tableOut{idxP+27,1}='Peak(HF)';tableOut{idxP+27,2}=arResult.peakHF;tableOut{idxP+27,3}='Hz';
    tableOut{idxP+28,1}='Power(VLF)';tableOut{idxP+28,2}=arResult.aVLF;tableOut{idxP+28,3}='ms²';
    tableOut{idxP+29,1}='Power(LF)';tableOut{idxP+29,2}=arResult.aLF;tableOut{idxP+29,3}='ms²';
    tableOut{idxP+30,1}='Power(HF)';tableOut{idxP+30,2}=arResult.aHF;tableOut{idxP+30,3}='ms²';
    tableOut{idxP+31,1}='Power(VLF)';tableOut{idxP+31,2}=arResult.pVLF;tableOut{idxP+31,3}='%';
    tableOut{idxP+32,1}='Power(LF)';tableOut{idxP+32,2}=arResult.pLF;tableOut{idxP+32,3}='%';
    tableOut{idxP+33,1}='Power(HF)';tableOut{idxP+33,2}=arResult.pHF;tableOut{idxP+33,3}='%';
    tableOut{idxP+34,1}='Power(LF)';tableOut{idxP+34,2}=arResult.nLF;tableOut{idxP+34,3}='n.u.';
    tableOut{idxP+35,1}='Power(HF)';tableOut{idxP+35,2}=arResult.nHF;tableOut{idxP+35,3}='n.u.';
    tableOut{idxP+36,1}='LF/HF';tableOut{idxP+36,2}=arResult.LFHF;

    tableOut{idxP+37,1}='非线性结果';
    pdResult = dataInfo.PDoutput;
    ndResult = dataInfo.NDoutput;
    tableOut{idxP+38,1}='SD1';tableOut{idxP+38,2}=pdResult.SD1;tableOut{idxP+38,3}='ms';
    tableOut{idxP+39,1}='SD2';tableOut{idxP+39,2}=pdResult.SD2;tableOut{idxP+39,3}='ms';
    tableOut{idxP+40,1}='SD2/SD1';tableOut{idxP+40,2}=pdResult.SDratio;
    tableOut{idxP+41,1}='SampEn';tableOut{idxP+41,2}=ndResult.sampen(end);
    tableOut{idxP+42,1}='DFA α';tableOut{idxP+42,2}=ndResult.dfa.alpha(1);
    tableOut{idxP+43,1}='DFA α1';tableOut{idxP+43,2}=ndResult.dfa.alpha1(1);
    tableOut{idxP+44,1}='DFA α2';tableOut{idxP+44,2}=ndResult.dfa.alpha2(1);

end