function tableOut = tableTDProcess(data1, data2, bpm, fs)
%% 时域HRV参数结果列表
%列表中结果显示为字符串类型
%UITable控件默认显示属性为：字符串靠左，数字靠右，此处没有可以调整为居中显示的设置
    tableOut = []; 
    if ~isempty(bpm)||~isempty(fs)
        i = 0; %数据完整时默认排序

    %呼吸频率计算结果：
    tableOut{1,1}='Resp_bpm';tableOut{2,1}='Resp_fs';
    tableOut{1,4}='bpm';tableOut{2,4}='Hz';
    %呼吸次数检测结果，输入结果为数字，转换为字符串后与后面时域分析结果位置统一
    tableOut{1,2} = num2str(bpm); tableOut{2,2} = num2str(fs);
    else
        i = -2; %无呼吸结果输入，整体向上两行，覆盖呼吸结果
    end

    tableOut{i+3,1}='MeanRR';tableOut{i+4,1}='SDNN';tableOut{i+5,1}='MeanHR';
    tableOut{i+6,1}='SDHR';tableOut{i+7,1}='RMSSD';tableOut{i+8,1}='NNx';
    tableOut{i+9,1}='pNNx';tableOut{i+10,1}='SDNNi';
    tableOut{i+11,1}='HRVti';tableOut{i+12,1}='TINN';
    tableOut{i+13,1}='Stress Index';

    tableOut{i+3,4}='ms';tableOut{i+4,4}='ms';tableOut{i+5,4}='bpm';
    tableOut{i+6,4}='bpm';tableOut{i+7,4}='ms';tableOut{i+8,4}='count';
    tableOut{i+9,4}='%';tableOut{i+10,4}='ms';tableOut{i+11,4}='';tableOut{i+12,4}='ms';
    tableOut{i+13,4}='';


        %时域指标结果
    [out1, out2] = diffProcess(data1.mean, data2.mean);
    tableOut{i+3,2} = out1; tableOut{i+3,3} = out2;
    
    [out1, out2] = diffProcess(data1.SDNN, data2.SDNN);
    tableOut{i+4,2} = out1; tableOut{i+4,3} = out2;
    
    [out1, out2] = diffProcess(data1.meanHR, data2.meanHR);
    tableOut{i+5,2} = out1; tableOut{i+5,3} = out2;
    
    [out1, out2] = diffProcess(data1.sdHR, data2.sdHR);
    tableOut{i+6,2} = out1; tableOut{i+6,3} = out2;
    
    [out1, out2] = diffProcess(data1.RMSSD, data2.RMSSD);
    tableOut{i+7,2} = out1; tableOut{i+7,3} = out2;
    
    [out1, out2] = diffProcess(data1.NNx, data2.NNx);
    tableOut{i+8,2} = out1; tableOut{i+8,3} = out2;
    
    [out1, out2] = diffProcess(data1.pNNx, data2.pNNx);
    tableOut{i+9,2} = out1; tableOut{i+9,3} = out2;
    
    [out1, out2] = diffProcess(data1.SDNNi, data2.SDNNi);
    tableOut{i+10,2} = out1; tableOut{i+10,3} = out2;
    
    [out1, out2] = diffProcess(data1.HRVTi, data2.HRVTi);
    tableOut{i+11,2} = out1; tableOut{i+11,3} = out2;
    
    [out1, out2] = diffProcess(data1.TINN, data2.TINN);
    tableOut{i+12,2} = out1; tableOut{i+12,3} = out2;
    
    [out1, out2] = diffProcess(data1.SI, data2.SI);
    tableOut{i+13,2} = out1; tableOut{i+13,3} = out2;

end