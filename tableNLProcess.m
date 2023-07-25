function tableOut = tableNLProcess(data1PD, data1ND, data2PD, data2ND)
%% 非线性HRV参数结果列表

    tableOut = [];
    tableOut{1,1}='SD1';tableOut{2,1}='SD2';
    tableOut{3,1}='SD2/SD1';tableOut{4,1}='SampEn';
    tableOut{5,1}='DFA α';tableOut{6,1}='DFA α1';
    tableOut{7,1}='DFA α2';
    tableOut{1,4}='ms';tableOut{2,4}='ms';
    
    [out1, out2] = diffProcess(data1PD.SD1, data2PD.SD1);
    tableOut{1,2} = out1; tableOut{1,3} = out2;
    
    [out1, out2] = diffProcess(data1PD.SD2, data2PD.SD2);
    tableOut{2,2} = out1; tableOut{2,3} = out2;
    
    [out1, out2] = diffProcess(data1PD.SDratio, data2PD.SDratio);
    tableOut{3,2} = out1; tableOut{3,3} = out2;
    
    [out1, out2] = diffProcess(data1ND.sampen(end), data2ND.sampen(end));
    tableOut{4,2} = out1; tableOut{4,3} = out2;
    
    [out1, out2] = diffProcess(data1ND.dfa.alpha(1), data2ND.dfa.alpha(1));
    tableOut{5,2} = out1; tableOut{5,3} = out2;
    
    [out1, out2] = diffProcess(data1ND.dfa.alpha1(1), data2ND.dfa.alpha1(1));
    tableOut{6,2} = out1; tableOut{6,3} = out2;
    
    [out1, out2] = diffProcess(data1ND.dfa.alpha2(1), data2ND.dfa.alpha2(1));
    tableOut{7,2} = out1; tableOut{7,3} = out2;

end