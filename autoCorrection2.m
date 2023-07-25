function [IBIAna, R_loc] = autoCorrection2(R_loc,Fs,ECG_fil_base)
%% R峰自动校正

%流程为，先找到R峰周围的最佳峰峰值点，再以此为基础，删除过低的点，在进行先增再删的工作
stander=Fs*60/90;
R_loc=peakcheck(R_loc,ECG_fil_base,Fs);
[R_loc,~]=deletelow(R_loc,ECG_fil_base);

R_loc=[2 R_loc length(ECG_fil_base)-1];%防止delete出现错误
IBIAna = IBIcalc(R_loc, Fs);

% [Rpeak,IBIAna]=deletelow(Rpeak,ECG_fil_base);
IBI=round(IBIAna(:,2)*Fs);
% h=find(IBI>mean(IBI)*1.8);
% for i=1:5
[IBIAna,R_loc]=addnewpeak(IBI,R_loc,stander,IBIAna,ECG_fil_base,Fs);

[IBIAna,R_loc]=deletepeak(R_loc,stander,IBIAna,ECG_fil_base,Fs);

IBI=IBIAna(:,2);
% IBI=IBIAna(:,2);
[R_loc,IBIAna]=deletelow(R_loc,ECG_fil_base);
% IBI=IBIAna(:,2);
% end

% IBIAna=IBIAna/Fs;
% Rpeak=ceil(Rpeak);
end

%%子函数：
function Rpeak=peakcheck(Rpeak,ECG_fil_base,Fs)
del=round(Fs*0.1);
for i=1:length(Rpeak)
    if Rpeak(i)<del
        continue
    end
    dat=ECG_fil_base(Rpeak(i)-del:Rpeak(i)+del);
    [~,peakloc]=findpeaks(dat);
    if length(peakloc)>1
        h=peakslope(dat,peakloc,2);
        peak=Rpeak(i)+peakloc(h)-del-1;
        Rpeak(i)=peak;
    end
    
end
end

function [IBIAna,Rpeak]=addnewpeak(IBI,Rpeak,stander,IBIAna,ECG_fil_base,Fs)
h=find(IBI>=stander);
h=unique([1;h;length(IBI)]);
mark=floor(IBI(h)/stander);
% mark=mark;
l=[];
for i=1:length(mark)
    dat=ECG_fil_base(Rpeak(h(i)):Rpeak(h(i)+1));
    if length(dat)<stander*0.2
        continue
    else
        [peak,loc]=findpeaks(dat,'MinPeakDistance', stander*0.3, 'MinPeakHeight',max(dat)/3);
    end
    if ~isempty(peak)
        if size(peak,1)<size(peak,2)
            peak=peak';
            loc=loc';
        end
        loc=loc+Rpeak(h(i));
%         m=sortrows([peak loc],1,'descend');
%         if length(peak)<mark(i)
%             mark(i)=length(peak);
%         end
%         t1=sort(m(1:mark(i),2)+Rpeak(h(i)-1));
%         l1=diff([Rpeak(h(i));t1]);
%         t=[t;t1];
        l=[l;loc];
    end
%     m=floor((Rpeak(h(i)+1)-Rpeak(h(i)))/mark(i));
%     l=[l m*ones(1,mark(i))]; 
%     m1=ones(1,mark(i)) * Rpeak(h(i));
%     t=[t m1 + m * ((1:mark(i)))];
end
Rpeak=[Rpeak  l'];
Rpeak=sort(Rpeak);
IBIAna = IBIcalc(Rpeak, Fs);
% mm=setdiff(1:size(IBI,1),h);
% IBIAna=IBIAna(mm,:);
% IBIAna=[IBIAna;[t l]];
% IBIAna=sortrows(IBIAna,1);
% Rpeak=[Rpeak(1);round(IBIAna(:,1)*Fs)];
end

function [IBIAna,Rpeak]=deletepeak(Rpeak,stander,IBIAna,ECG_fil_base,Fs)
for j=1:1
IBI=round(IBIAna(:,2)*Fs);
h1=find(IBI<stander*0.3);
if isempty(h1)
    return
else
    for i=1:length(h1)
        %      [~,k]=min(ECG_fil_base(Rpeak(h1(i)+1)),ECG_fil_base(Rpeak(h1(i))));%IBI过小，选较大的R峰
        k=peakslope(ECG_fil_base,[Rpeak(h1(i)) Rpeak(h1(i)+1)],1);
        h2(i)=h1(i)+(k-1);
    end
    h=setdiff(1:length(Rpeak),h2);
    Rpeak=Rpeak(h);
    h=setdiff(1:size(IBIAna,1),h1);
    IBIAna=IBIAna(h,:);
    if Rpeak(1)==2
        Rpeak=Rpeak(2:end);
    end
    if Rpeak(end)==length(ECG_fil_base)-1
        Rpeak=Rpeak(1:end-1);
    end
    IBIAna = IBIcalc(Rpeak, Fs);
end
end
end

function [Rpeak,IBIAna]=deletelow(Rpeak,ECG_fil_base)
%此步骤不是太科学，可去掉
rpeak=ECG_fil_base(Rpeak);
st=quantile(rpeak,0.5);
h=find(rpeak<st*0.3);
h1=setdiff(1:length(Rpeak),h);
Rpeak=Rpeak(h1);
IBI=diff(Rpeak);
IBIAna=[Rpeak(2:end);IBI]';
end
% function [Rpeak,IBIAna]=deletelow(Rpeak,IBI,ECG_fil_base)
% rpeak=ECG_fil_base(Rpeak(2:end));
% st=mean(rpeak);
% h=find(rpeak<st*0.5);
% h1=setdiff(1:length(IBI),h);
% Rpeak=[Rpeak(1) Rpeak(h1+1)];
% IBI=diff(Rpeak);
% IBIAna=[Rpeak(2:end);IBI]';
% end
function h=peakslope(dat,peakloc,mode)
for i=1:length(peakloc)
slopes(1)=abs(dat(peakloc(i)+1)-dat(peakloc(i)));
slopes(2)=abs(dat(peakloc(i))-dat(peakloc(i)-1));
slope(i)=sum(slopes)*peakloc(i);
end
if mode==1
    [~,h]=min(slope);
else
    [~,h]=max(slope);
end

end

function IBIAna = IBIcalc(Rpeak, Fs)
%% IBI计算
RpeakTime = Rpeak/Fs;%每个峰的时间
IBI = diff(RpeakTime); % 差分    峰间距离
IBI(IBI==0)=mean(IBI); %将IBI中等于0的值全部替换为均值 
IBIAna = [];
IBIAna(:,1) = RpeakTime(2:end);IBIAna(:,2) = IBI;
end