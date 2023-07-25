function [Rtime, ECG, RtimeR, Rpeak, IBI] = deletePoints(correctRange, datainfo, ax)
%% 在坐标区删除点，选取附近极大值点

    x = datainfo.Rtime;
    y = datainfo.ECG;
    mx = datainfo.RtimeR;
    my = datainfo.Rpeak';
    [m,~] = size(mx);
    if m ~= 1
        mx = mx';
    end
    
    [flag, maxIdx] = maxInRange(correctRange, y, mx, x, ax);
    % 范围内有R峰，则删除R峰
    if flag
        mx(maxIdx) = [];
        my(maxIdx) = [];
    end
    Rtime = x;
    ECG = y;
    RtimeR = mx;
    Rpeak = my';
    IBI(:,1) = mx(2:end);IBI(:,2) = diff(mx)';
end