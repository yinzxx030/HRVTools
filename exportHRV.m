function exportHRV(parameter, newpath, filename, dataInfo)
%% 保存HRV结果

    startTime = parameter.startTime;
    windowTime = parameter.windowTime;

    % 进入默认位置
    oldpath = cd;
    if isempty(newpath)
        newpath = cd;
    end
    cd(newpath);

    % 打开选择文件对话框
    [fileName, pathName] = uiputfile([filename '_HRV' '.xlsx'],'保存HRV结果');
    
    cd(oldpath);
    
    % 如果未选择文件则直接返回
    if ~fileName
        return;
    else
        str = [pathName fileName]; 
        
        % 保存数据
        writecell(tableHRV(dataInfo, startTime, windowTime), char(str));
        msgbox('HRV分析结果文件保存成功')
    end
end