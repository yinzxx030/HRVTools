function [data1,data2] = writefactortable(dataTD, dataPD)
 meanRR =  dataTD.mean;
 RMSSD = dataTD.RMSSD;
 PNN50 = dataTD.pNNx;

 meanHR = dataTD.meanHR;
 SI = dataTD.SI; 
 SD1 = dataPD.SD1;

 data1 = cell(1, 3); data2 = cell(1,3);
 data1{1} = [num2str(meanRR), 'ms'];
 data1{2} = [num2str(RMSSD), 'ms'];
 data1{3} =[num2str(PNN50), '%'];

 data2{1} = [num2str(meanHR),'bpm']; 
 data2{2} = [num2str(SI),' ']; 
 data2{3} = [num2str(SD1),'%']; 

end