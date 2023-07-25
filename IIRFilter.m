function filterd = IIRFilter(sig,fs,order,tag, f1, f2)
%默认巴特沃斯
if nargin ==6
    wn1 = f1*2/fs;
    wn2 = f2*2/fs;
    Wn = [wn1 wn2];
else
    Wn = f1*2/fs;
end
switch(tag)
    case 'HPF'
        [Bb ,Ba]=butter(order,Wn,'high'); 
    case 'LPF'
        [Bb ,Ba]=butter(order,Wn,'low'); 
    case 'BPF'
        [Bb ,Ba]=butter(order,Wn,'bandpass'); 
end

filterd=filtfilt(Bb,Ba,sig); % 进行高通滤波 
end