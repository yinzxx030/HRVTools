function exportPDF(filename, newpath, figure)
% input:
% UIAxes_ECG：心电波形图
% UIAxes_RR：RR折线图
% hrvtableT：时域HRV结果表格
% hrvtableF：频域HRV结果表格
% hrvtableN：非线性HRV结果表格
% histoRR、histoHR：RR、HR直方图
% AR：AR频谱图

% 进入默认位置
oldpath = cd;
if isempty(newpath)
    newpath = cd;
end
cd(newpath);

% 打开选择文件对话框
[fileName, pathName] = uiputfile([filename '_HRV分析报告' '.pdf'],'保存PDF结果');

cd(oldpath);

% 如果未选择文件则直接返回
if ~fileName
    return;
else
    % 保存数据
    str = [pathName fileName];

%     print(figure, str, '-dpdf','-r0');
    saveas(figure, str); %figure的visible属性为off时可运行

    msgbox('HRV分析结果报告保存成功')
end
end