function results = IBISample(IBI, startTime, windowTime)
%% IBI截取
    idx1 = find(IBI(:,1) >= startTime, 1, 'first');
    idx2 = find(IBI(:,1) <= startTime+windowTime, 1, 'last');
    results = IBI(idx1 : idx2, :);
end