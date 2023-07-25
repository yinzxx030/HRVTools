function R_loc = autoCorrection(Fs, ECG, R_loc, tag)
%% R峰自动校正
    if strcmp(tag, 'PT')
        % 将R峰邻域左右各0.05秒范围内极大值调整为R峰
        range = round(0.05*Fs); 
        for i=1:length(R_loc)
            R_loc_now = R_loc(i);
            left = R_loc_now - range;
            right = R_loc_now + range;
            if left < 1
                left = 1;
            end
            if right > length(ECG)
               right = length(ECG);
            end
            [~,n] = max(ECG(left:right));
            R_loc(i) = left + n - 1;
        end
    elseif strcmp(tag, 'kota')
        % 根据阈值上下限添加或者删除R峰点
        % 比较相邻R峰的差值，若小于阈值，则比较该两处R峰的幅度大小，删除幅度小的
        % 比较相邻R峰的差值，若大于阈值，则从左边R峰开始距离RR平均值处寻找邻域极大值逐次插入R峰
        RR = diff(R_loc);
        [~, maxIdx] = max(RR);
        RR(maxIdx) = []; % 去除一个最大值
        zeroIdx = RR==0;
        RR(zeroIdx) = []; % 去除0值
        meanRR = round(mean(RR)); % 平均RR间隔样本点差
        low = round(meanRR*0.5); % 阈值下限，为平均RR的一半
        up = round(meanRR*2); % 阈值上限 为平均RR的两倍
        range = round(0.3*Fs); % 插值邻域范围，默认0.3
    
        i=2;
        while i<length(R_loc)
            dev = R_loc(i+1)-R_loc(i); % 相邻R峰时间差
            if dev==0 % 如果时间差为零
                R_loc(i+1) = []; % 则删除后一个R峰
            elseif dev<low % 如果时间差比下阈值小
                if ECG(R_loc(i+1)) < ECG(R_loc(i)) % 比较相邻R峰的幅度，若后一个小于前一个
                    R_loc(i+1) = []; % 则删除后一个R峰
                else % 若后一个大于等于前一个
                    dev1 = R_loc(i+1)-R_loc(i-1); % 比较前两个和后一个时间差
                    if dev1 < up % 若小于上阈值
                        R_loc(i) = []; % 则删除前一个R峰
                    else
                        R_loc(i+1) = []; % 则删除后一个R峰
                    end
                end
            elseif dev>up % 如果时间差比上阈值大
                % 寻找邻域范围内极大值
                idx = R_loc(i)+meanRR;
                [~,n] = max(ECG(idx-range:idx+range));
                inter = idx-range + n - 1;
                R_loc = [R_loc(1:i) inter R_loc(i+1:end)];
                i=i+1;
            else
                i = i+1; % 时间差正常，则遍历下一个点
            end 
        end
    end
end