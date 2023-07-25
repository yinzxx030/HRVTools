function [flag, maxIdx] = maxInRange(correctRange, ECG, RtimeR, x, ax)
%% 检查给定元素在数组x中指定临近范围内是否含有R峰，有则返回R峰，否则返回范围内最大值
    
    idx = find(x <= ax, 1, 'last');
    % 左右范围
    left = round(idx - correctRange/2);
    right = round(idx + correctRange/2);
    if left < 1 
        left = 1;
    end
    if right > length(x)
        right = length(x);
    end

    % 检查范围内是否有R峰
    Rpeak = intersect(x(left : right), RtimeR);

    if isempty(Rpeak)
        flag = false;
        maxNum = max(ECG(left : right));
        maxIdxTemp = find(ECG == maxNum);
        % 若存在多个最大值，则取最前面的
        maxIdx = maxIdxTemp(1);
    else
        flag = true;
        % 若存在多个R峰，则取最前面的
        maxIdx = find(RtimeR == Rpeak(1));
    end
end