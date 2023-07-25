function signal_filter = butterfilter(signal,Fs,fp,fs)
%input: signal为ECG或Respiration
%fp = 0.8; fs = 1.2为通带截止频率，阻带截止频率，该参数为ECG滤波参数
%Fs：信号采样率
rp = 3; rs = 5;                     %通带、阻带衰减（ECG与呼吸信号通用）
wp = 2*pi*fp; ws = 2*pi*fs;   
[n,wn] = buttord(wp,ws,rp,rs,'s'); %'s'是确定巴特沃斯模拟滤波器阶次和3dB截止模拟频率
[z,P,k] = buttap(n);   %设计归一化巴特沃斯模拟低通滤波器，z为极点，p为零点和k为增益
[bp,ap] = zp2tf(z,P,k);  %转换为Ha(p),bp为分子系数，ap为分母系数
[bs,as] = lp2lp(bp,ap,wp); %Ha(p)转换为低通Ha(s)并去归一化，bs为分子系数，as为分母系数
[bz,az] = bilinear(bs,as,Fs);     %对模拟滤波器双线性变换
signal_filter = filter(bz,az,signal);
end

