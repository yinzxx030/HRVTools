function [TIME, ECG] = importMITData(pathName, fileName, SAMPLES2READ, channel)
%%
%------ LOAD HEADER DATA --------------------------------------------------
%------ 读入头文件数据 -----------------------------------------------------
headFile = [fileName(1:end-4) '.hea']; 
signalh = fullfile(pathName, headFile); % 通过函数 fullfile 获得头文件的完整路径
fid1 = fopen(signalh,'r'); % 打开头文件，其标识符为 fid1 ，属性为 r –“只读”
z = fgetl(fid1); % 读取头文件的第一行数据，字符串格式
A = sscanf(z, '%*s %d %d %d', [1,3]); % 按照格式 '%*s %d %d %d  转换数据并存入矩阵 A 中
nosig = A(1); % 信号通道数目
sfreq = A(2); % 数据采样频率
clear A; % 清空矩阵A，准备获取下一行数据
for k = 1 : nosig % 读取每个通道信号的数据信息
    z = fgetl(fid1);
    A = sscanf(z, '%*s %d %d %d %d %d', [1,5]);
    dformat(k) = A(1); % 信号格式; 这里只允许为 212 格式
    if A(2)==0 A(2)=200;end
    gain(k) = A(2); % 每 mV 包含的整数个数
    bitres(k) = A(3); % 采样精度（位分辨率）
    if A(4)==0 A(4)=1024;end
    zerovalue(k) = A(4); % ECG 信号零点相应的整数值
    firstvalue(k) = A(5); % 信号的第一个整数值 (用于偏差测试)
end
fclose(fid1);
clear A;

%------ LOAD BINARY DATA --------------------------------------------------
%------ 读取 ECG 信号二值数据 ----------------------------------------------
if dformat ~= [212,212], error('this script does not apply binary formats different to 212.'); end
signald = fullfile(pathName, fileName); % 读入 212 格式的 ECG 信号数据
fid2 = fopen(signald,'r');
A = fread(fid2, [3, SAMPLES2READ], 'uint8')'; % matrix with 3 rows, each 8 bits long, = 212bit
fclose(fid2);
% 通过一系列的移位（bitshift）、位与（bitand）运算，将信号由二值数据转换为十进制数
M2H = bitshift(A(:,2), -4); %字节向右移四位，即取字节的高四位
M1H = bitand(A(:,2), 15); %取字节的低四位
PRL = bitshift(bitand(A(:,2), 8), 9); % sign-bit 取出字节低四位中最高位，向右移九位
PRR = bitshift(bitand(A(:,2), 128), 5); % sign-bit 取出字节高四位中最高位，向右移五位
M = [];
M(:, 1) = bitshift(M1H, 8) + A(:, 1) - PRL;
M(:, 2) = bitshift(M2H, 8) + A(:, 3) - PRR;
if M(1,:) ~= firstvalue, error('inconsistency in the first bit values'); end
switch nosig
case 2
    M(:, 1)= (M(:, 1) - zerovalue(1)) / gain(1);
    M(:, 2)= (M(:, 2) - zerovalue(2)) / gain(2);
    TIME=(0:(SAMPLES2READ-1)) / sfreq;
case 1
    M(:, 1) = (M(:, 1) - zerovalue(1));
    M(:, 2) = (M(:, 2) - zerovalue(1));
    M = M';
    M(1) = [];
    sM = size(M);
    sM = sM(2) + 1;
    M(sM) = 0;
    M = M';
    M = M / gain(1);
    TIME = (0:2*(SAMPLES2READ)-1)/sfreq;
otherwise % this case did not appear up to now!
    % here M has to be sorted!!!
    disp('Sorting algorithm for more than 2 signals not programmed yet!');
end
ECG = M(:, channel); % 默认读取第一通道数据
clear A M1H M2H PRR PRL;
end