function results = calcTime(time, flag)
    if strcmp(flag, 'time2str')
        % 将秒数时间转换成HH:MM:SS格式
        x1 = fix(time/3600);
        x2 = fix(mod(time,3600)/60);
        x3 = fix(mod(mod(time,3600),60));
        results = [numConvert(x1), ': ', numConvert(x2), ': ', numConvert(x3)];
    elseif strcmp(flag, 'str2time')
        % 将HH:MM:SS时间转换为秒数时间
        str = strsplit(time,':');
        if length(str) ~= 3
            msgbox('请输入正确的时间')
        else
            x1 = corr(str2double(str(1)));
            x2 = corr(str2double(str(2)));
            x3 = corr(str2double(str(3)));
            results = x1*3600+x2*60+x3;
        end
    elseif strcmp(flag, 'timeArr2str')
        % 将秒数时间序列转换成HH:MM:SS格式
        for i=1:length(time)
            x1 = fix(time(i)/3600);
            x2 = fix(mod(time(i),3600)/60);
            x3 = fix(mod(mod(time(i),3600),60));
            results{i} = [numConvert(x1), ':', numConvert(x2), ':', numConvert(x3)];
        end
    end
end

% 将个位数字前面加上'0'，例如'9'->'09'，符合时间显示
function results = numConvert(time)
    if time < 10
        results = ['0',num2str(time)];
    else
        results = num2str(time);
    end
end

% 保证时分秒不超过限制
function num = corr(time)
    if time < 0
        num = 0;
    elseif time > 59
        num = 59;
    else
        num = time;
    end
end