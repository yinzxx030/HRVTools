% 计算差值
function [out1, out2] = diffProcess(data1, data2)
out2 = num2str(data2);
difference = data1 - data2;
if difference > 0
    difference = ['+' num2str(difference)];
else
    difference = num2str(difference);
end
out1 = [num2str(data1) ' (' difference ')'];
end