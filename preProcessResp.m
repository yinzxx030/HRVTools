function Resp_fil_all = preProcessResp(Resp, Fs)
%% 呼吸信号预处理

%--------------中值滤波消除基线漂移(窗长需要根据呼吸频率改变，否则波形失真)-----------------------------
Resp_fil_base = myMedfilt(Resp, 1300);
%--------------------------低通滤波器滤除工频干扰---------------------------
Resp_fil_all = butterfilter(Resp_fil_base, Fs,0.4, 0.5);
end

function [y] = myMedfilt(x, R)
    y = x;
    for i = 1:length(x)
        if ((i+R)<= length(x) && (i-R)>= 1)
            BL = median(x((i-R):(i+R)));
        elseif ((i+R)<= length(x) && (i-R)< 1)
            BL = median(x(1:(i+R)));
        elseif ((i+R)> length(x) && (i-R)>= 1)
            BL = median(x((i-R):end));
        end
        y(i) = y(i)- BL;
    end
end
