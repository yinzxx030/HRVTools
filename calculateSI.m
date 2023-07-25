function [SI] = calculateSI(ibi, t)
% 
% input
% ibi: corrected RR intervals
%t_ibi:array of time (s)
% output
% SI: Baevsky’s Stress index
%
% 还需要对ibi进行平滑先验滤波，函数在下面（去趋势，以去除）
try   
    ibi = detrending(ibi, t);
catch
end
    % 画直方图（bin宽50ms）
    figure("Visible","off");
    h=histogram(ibi,'BinWidth',0.05);
    hold off

    % 计算
    amo = max(h.Values) / length(ibi) ; %取直方图中数量最多的ibi区间，计算其占比amo为[0,1]
    moIndex = find(h.Values == max(h.Values)); 
    mo = (h.BinEdges(moIndex) + h.BinEdges(moIndex+1))/2; %取直方图最高块两边界中点为众数
    mxDmn = max(ibi) - min(ibi); % 直方图的宽
    % 计算SI参数
    SI = amo * 100 / (2*mo(1)*mxDmn);

    % 开平方根，使SI更接近正态分布
    SI = sqrt(SI);


function [z_stat] = detrending(z, t)
%
% 对数据z进行去趋势
% 插值至4Hz，然后lambda设置为300
% 结果是：数据将会移至零轴附近
%
    fs = 4;
    % RR间隔三次样条插值，插值频率4Hz
    t2 = t(1):1/fs:t(length(t));
    z=interp1(t,z,t2','spline');
    % 设置lambda
    lambda = 300;
    
    % 去趋势
    T =  length(z);
    I = speye(T); %构建稀疏单位矩阵
    D2 = spdiags(ones(T-2,1)*[1 -2 1], [0:2], T-2, T); %创建对角矩阵
    z_stat = (I - inv(I + lambda^2 *D2' *D2)) *z; %最终结果为列向量
    
    z_stat = z_stat + mean(z);
end

end
