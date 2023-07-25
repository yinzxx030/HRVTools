function exportRR(newpath, filename, IBI)
%% 保存RR数据

    % 进入默认位置
    oldpath = cd;
    if isempty(newpath)
        newpath = cd;
    end
    cd(newpath);

    % 打开选择文件对话框
    [fileName, pathName] = uiputfile([filename '_RR' '.xlsx'],'保存RR间隔文件');
    
    cd(oldpath);
    
    % 如果未选择文件则直接返回
    if ~fileName
        return;
    else
        str = [pathName fileName]; 
 
        % 列名称
        title={'RtimeR','RR'};
        result_table = table(IBI(:,1),roundn(IBI(:,2), -3),'VariableNames',title);
        
        % 保存数据
        writetable(result_table, char(str));
    end
end