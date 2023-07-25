function [Rtime, ECG, RtimeR, Rpeak, IBI] = addPoints(correctRange, datainfo, ax)
%% 在坐标区添加点，选取附近极大值点
% ax:添加点的横坐标

    x = datainfo.Rtime;
    y = datainfo.ECG;
    mx = datainfo.RtimeR;
    my = datainfo.Rpeak';
    [m,~] = size(mx);
    if m ~= 1
        mx = mx';
    end
    
    [flag, maxIdx] = maxInRange(correctRange, y, mx, x, ax);
    % 范围内没有R峰，则标记范围内最大值为R峰
    if ~flag
        ax = x(maxIdx);
        ay = y(maxIdx);
        idx1 = find(mx >= ax, 1, 'first');
        if idx1 == 0
            mx = [ax mx];
            my = [ay my];
        elseif isempty(idx1)
            mx = [mx ax];
            my = [my ay];
        else
            mx = [mx(1:idx1-1) ax mx(idx1:end)];
            my = [my(1:idx1-1) ay my(idx1:end)];
        end
    end
    Rtime = x;
    ECG = y;
    RtimeR = mx;
    Rpeak = my';
    IBI(:,1) = mx(2:end);IBI(:,2) = diff(mx)';
end