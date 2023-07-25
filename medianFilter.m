function [y] = medianFilter(x, R)
%% 中值滤波子函数
    y = x;
    for i = 1:length(x)
        if ((i+R)<= length(x) && (i-R)>= 1)
            BL = median(x((i-R):(i+R)));
        elseif ((i+R)<= length(x) && (i-R)< 1)
            BL = median(x(1:(i+R)));
        elseif ((i+R)> length(x) && (i-R)>= 1)
            BL = median(x((i-R):end));
        else
            BL = 0;
        end
        y(i) = y(i)- BL;
    end
end