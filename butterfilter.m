function signal_filter = butterfilter(signal,Fs,fp,fs)
%input: signalΪECG��Respiration
%fp = 0.8; fs = 1.2Ϊͨ����ֹƵ�ʣ������ֹƵ�ʣ��ò���ΪECG�˲�����
%Fs���źŲ�����
rp = 3; rs = 5;                     %ͨ�������˥����ECG������ź�ͨ�ã�
wp = 2*pi*fp; ws = 2*pi*fs;   
[n,wn] = buttord(wp,ws,rp,rs,'s'); %'s'��ȷ��������˹ģ���˲����״κ�3dB��ֹģ��Ƶ��
[z,P,k] = buttap(n);   %��ƹ�һ��������˹ģ���ͨ�˲�����zΪ���㣬pΪ����kΪ����
[bp,ap] = zp2tf(z,P,k);  %ת��ΪHa(p),bpΪ����ϵ����apΪ��ĸϵ��
[bs,as] = lp2lp(bp,ap,wp); %Ha(p)ת��Ϊ��ͨHa(s)��ȥ��һ����bsΪ����ϵ����asΪ��ĸϵ��
[bz,az] = bilinear(bs,as,Fs);     %��ģ���˲���˫���Ա任
signal_filter = filter(bz,az,signal);
end

