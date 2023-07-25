function filterd = FIRFilter(sig, fs, order, tag, f1, f2)
L=order; %窗口长度
beta = 80; %衰减系数
wc1 = f1/fs*pi; %截止频率
if nargin==6
    wc2 = f2/fs*pi;
end
switch (tag)
    case 'HPF'
        h = -ideal_lp(wc1,order);
    case 'LPF'
        h = ideal_lp(wc1,order);
    case 'BPF'
        h = ideal_lp(wc2,order)-ideal_lp(wc1,order);
    case 'BSF'
        h = ideal_lp(wc1,order)-ideal_lp(wc2,order);
end
w = kaiser(L,beta);
y = h.*rot90(w); %冲激响应序列
filterd = filtfilt(y,1,sig);
end