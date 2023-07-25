function tableOut = tableFDProcess(inputData1, inputData2, method)
%% 频域HRV参数结果列表

    tableOut = [];
    tableOut{1,1}='Peak(VLF)';tableOut{2,1}='Peak(LF)';tableOut{3,1}='Peak(HF)';
    tableOut{1,4}='Hz';tableOut{2,4}='Hz';tableOut{3,4}='Hz';
    tableOut{4,1}='Power(VLF)';tableOut{5,1}='Power(LF)';tableOut{6,1}='Power(HF)';
    tableOut{4,4}='ms²';tableOut{5,4}='ms²';tableOut{6,4}='ms²';
    tableOut{7,1}='Power(VLF)';tableOut{8,1}='Power(LF)';tableOut{9,1}='Power(HF)';
    tableOut{7,4}='log';tableOut{8,4}='log';tableOut{9,4}='log';
    tableOut{10,1}='Power(VLF)';tableOut{11,1}='Power(LF)';tableOut{12,1}='Power(HF)';
    tableOut{10,4}='%';tableOut{11,4}='%';tableOut{12,4}='%';
    tableOut{13,1}='Power(LF)';tableOut{14,1}='Power(HF)';
    tableOut{13,4}='n.u.';tableOut{14,4}='n.u.';
    tableOut{15,1}='LF/HF';
    
    if strcmp(method, 'welch')
        data1 = inputData1.welch.hrv;
        data2 = inputData2.welch.hrv;
    elseif strcmp(method, 'ar')
        data1 = inputData1.ar.hrv;
        data2 = inputData2.ar.hrv;
    end
    
    %% peak
    [out1, out2] = diffProcess(data1.peakVLF, data2.peakVLF);
    tableOut{1,2} = out1; tableOut{1,3} = out2;
    
    [out1, out2] = diffProcess(data1.peakLF, data2.peakLF);
    tableOut{2,2} = out1; tableOut{2,3} = out2;
    
    [out1, out2] = diffProcess(data1.peakHF, data2.peakHF);
    tableOut{3,2} = out1; tableOut{3,3} = out2;
    
    %% power(ms^2)
    [out1, out2] = diffProcess(data1.aVLF, data2.aVLF);
    tableOut{4,2} = out1; tableOut{4,3} = out2;
    
    [out1, out2] = diffProcess(data1.aLF, data2.aLF);
    tableOut{5,2} = out1; tableOut{5,3} = out2;
    
    [out1, out2] = diffProcess(data1.aHF, data2.aHF);
    tableOut{6,2} = out1; tableOut{6,3} = out2;
    
    %% power(log)
    [out1, out2] = diffProcess(data1.logVLF, data2.logVLF);
    tableOut{7,2} = out1; tableOut{7,3} = out2;
    
    [out1, out2] = diffProcess(data1.logLF, data2.logLF);
    tableOut{8,2} = out1; tableOut{8,3} = out2;
    
    [out1, out2] = diffProcess(data1.logHF, data2.logHF);
    tableOut{9,2} = out1; tableOut{9,3} = out2;
    
        %% power(%)
    [out1, out2] = diffProcess(data1.pVLF, data2.pVLF);
    tableOut{10,2} = out1; tableOut{10,3} = out2;
    
    [out1, out2] = diffProcess(data1.pLF, data2.pLF);
    tableOut{11,2} = out1; tableOut{11,3} = out2;
    
    [out1, out2] = diffProcess(data1.pHF, data2.pHF);
    tableOut{12,2} = out1; tableOut{12,3} = out2;
  
    %% power(n.u.)
    [out1, out2] = diffProcess(data1.nLF, data2.nLF);
    tableOut{13,2} = out1; tableOut{13,3} = out2;
    
    [out1, out2] = diffProcess(data1.nHF, data2.nHF);
    tableOut{14,2} = out1; tableOut{14,3} = out2;
    
    %% LF/HF(ratio)
    [out1, out2] = diffProcess(data1.LFHF, data2.LFHF);
    tableOut{15,2} = out1; tableOut{15,3} = out2;

end