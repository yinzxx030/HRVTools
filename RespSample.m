function results = RespSample(Resp,Fs, startTime, windowTime)
%% 呼吸信号截取
    if ~isempty(Resp)
        idx1 = startTime*Fs+1;
        idx2 = (startTime+windowTime)*Fs;
        while length(Resp)<idx2
            idx2 = length(Resp);
        end
        
        results = Resp(idx1: idx2, :);
    else
        results = [];
    end
end