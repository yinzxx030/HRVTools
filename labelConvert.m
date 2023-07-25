function labelStr = labelConvert(tag)
%% 将标签转换为对应状态名称

    switch tag
        case 0
            labelStr = 'W';
        case 1
            labelStr = 'N1';
        case 2
            labelStr = 'N2';
        case 3
            labelStr = 'N3';
        case 5
            labelStr = 'R';
    end
end