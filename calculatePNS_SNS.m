function [PNS, SNS] = calculatePNS_SNS(dataTD, dataNL)
%input:
%dataTD：时域结果数组
%dataNL：非线性结果数组
%计算系数由Kubios结果与运用Matlab计算结果所拟合得出

 meanRR =  dataTD.mean;
 RMSSD = dataTD.RMSSD;
 PNN50 = dataTD.pNNx;

 meanHR = dataTD.meanHR;
 SI = dataTD.SI;
 TINN = dataTD.TINN;
 Hti = dataTD.HRVTi;
% 
 SD1 = dataNL.SD1;
 SD2 = dataNL.SD2;

%  PNS = -3.679+6.628e-02*meanRR-1.641e-02*RMSSD-2.777e-05*PNN50-4.21e-03*SD1;
%  SNS = -6.014+5.077e-02*meanHR-5.931e-04*SD2+4.787e-01*SI+7.144e-05*TINN-4.62e-03*Hti;

% PNS = -5.2797+0.0045*meanRR+0.0206*RMSSD+0.0143*PNN50;
% SNS = -6.2294+0.0492*meanHR+0.51681*SI;
PNS = -5.3909+0.0051*meanRR-3.5338*RMSSD+5.0211*SD1;
SNS = -8.0683+0.0889*meanHR+0.045*SI-0.0042*SD2;


end