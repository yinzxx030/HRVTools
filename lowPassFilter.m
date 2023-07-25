function ECG_filter = lowPassFilter(ECG1,Fs)
fp = 45; fs = 50;                  %ͨ����ֹƵ�ʣ������ֹƵ��
rp = 3; rs = 5;                     %ͨ�������˥��
wp = 2*pi*fp; ws = 2*pi*fs;   
[n,wn] = buttord(wp,ws,rp,rs,'s'); %'s'��ȷ��������˹ģ���˲����״κ�3dB��ֹģ��Ƶ��
[z,P,k] = buttap(n);   %��ƹ�һ��������˹ģ���ͨ�˲�����zΪ���㣬pΪ����kΪ����
[bp,ap] = zp2tf(z,P,k);  %ת��ΪHa(p),bpΪ����ϵ����apΪ��ĸϵ��
[bs,as] = lp2lp(bp,ap,wp); %Ha(p)ת��Ϊ��ͨHa(s)��ȥ��һ����bsΪ����ϵ����asΪ��ĸϵ��
[bz,az] = bilinear(bs,as,Fs);     %��ģ���˲���˫���Ա任
ECG_filter = filter(bz,az,ECG1);
end