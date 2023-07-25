function output = freqDomainHRV(ibi,VLF,LF,HF,AR_order,window, ...
    noverlap,nfft,fs,methods)
%freqDomainHRV - calculates freq domain HRV using FFT, AR
%methods
%
%Inputs:    ibi = 2Dim array of time (s) and inter-beat interval (s)
%           AR_order = order of AR model
%           window = # of samples in window
%           noverlap = # of samples to overlap
%           fs = cubic spline interpolation rate / resample rate (Hz)
%           nfft = # of points in the frequency axis
%           methods = cell array of strings that defines the methods used to
%               calculate freqDomain. The default is all to use
%               all three methods. 
%               methods={'welch','ar','lomb'}
%           flagPlot = flag to tell function to plot PSD. 1=plot,
%           0=don't plot, default is 0.
%Outputs:   output is a structure containg all HRV. One field for each 
%           PSD method.
%           Output units include:
%               peakHF,LF,VLF (Hz)
%               aHF,aLF,aVLF (ms^2)
%               pHF,pLF,pVLF (%)
%               nHF,nLF,nVLF (%)
%               PSD (ms^2/Hz)
%               F (Hz)
%Usage:  (1) To compute freq. domain HRV on a ibi data set named dIBI 
%        using VLF=[0.0-0.16], LF =[0.16-0.6], HF=[0.6 3], 
%        AR model order = 16, welch window width = 256, 
%        # of overlap pnts in welch window (50%) = 128, # of pnts in fft = 512, 
%        IBI resample rate = 10Hz
%        
%        Use: output = freqDomainHRV(sampledata,[0 .16],[.16 .6],[.6 3], ...
%                       16, 256, 128, 512, 10);
%
%        (2) To do the above and also plot all three power
%        spectrum densities (PSD)
%
%        Use: output = freqDomainHRV(sampledata,[0 .16],[.16 .6],[.6 3], ...
%                       16,256,128,512,10,{'welch','ar','lomb'},1);


    %check input
    if nargin<9
        error('Not enough input arguments!')
    end    
    
    t=ibi(:,1); %time (s)
    y=ibi(:,2); %ibi (s)     
    
    y=y.*1000; %convert ibi to ms
    %assumes ibi units are seconds
        
    %prepare y
    y=detrend(y,'linear');
    y=y-mean(y);
    
    if strcmpi(methods,'welch')
        %Welch FFT
        [output.psd,output.f] = calcWelch(t,y,window,noverlap,nfft,fs);
        output.hrv = calcAreas(output.f,output.psd,VLF,LF,HF);
    elseif strcmpi(methods,'ar')
        %AR
        [output.psd,output.f]=calcAR(t,y,fs,nfft,AR_order);
        output.hrv=calcAreas(output.f,output.psd,VLF,LF,HF);
    end
     
end

function [PSD,F]=calcWelch(t,y,window,noverlap,nfft,fs)
%calFFT - Calculates the PSD using Welch method.
%
%Inputs:
%Outputs:
    if find(diff(t)<=0)
        index = diff(t)<=0;
        t(index) = [];
        y(index) = [];
    end
    %Prepare y
    t2 = t(1):1/fs:t(length(t));%time values for interp.
    y=interp1(t,y,t2','spline')'; %cubic spline interpolation
    y=y-mean(y); %remove mean
    
    % 判断信号长度是否大于段的长度
    if length(y) < window
        msgbox('待分析数据时间段小于分段要求，请扩大时间范围！')
    end
    %Calculate Welch PSD using hamming windowing    
    [PSD,F] = pwelch(y,window,noverlap,(nfft*2)-1,fs,'onesided'); 
    
end

function [PSD,F]=calcAR(t,y,fs,nfft,AR_order)
%calAR - Calculates the PSD using Auto Regression model.
%
%Inputs:
%Outputs:
    if find(diff(t)<=0)
        index = diff(t)<=0;
        t(index) = [];
        y(index) = [];
    end   
    %Prepare y    
    t2 = t(1):1/fs:t(length(t)); %time values for interp.
    y=interp1(t,y,t2,'spline')'; %cubic spline interpolation
    y=y-mean(y); %remove mean
    y = y.*hamming(length(y)); %hamming window
    
    %Calculate PSD
    %Method 1
%     [A, variance] = arburg(y,AR_order); %AR using Burg method
%     [H,F] = freqz(1,A,nfft,fs);
%     PSD=(abs(H).^2).*(variance/fs); %malik, p.67    
    %Method 2
    [PSD,F]=pburg(y,AR_order,(nfft*2)-1,fs,'onesided');
    %Method 3
%      h=spectrum.burg;
%      hpsd = psd(h, y, 'NFFT', nfft, 'Fs', 2);
%      F=hpsd.Frequencies;
%      PSD=hpsd.Data;
     
end

function output=calcAreas(F,PSD,VLF,LF,HF,flagNorm)
%calcAreas - Calulates areas/energy under the PSD curve within the freq
%bands defined by VLF, LF, and HF. Returns areas/energies as ms^2,
%percentage, and normalized units. Also returns LF/HF ratio.
%
%Inputs:
%   PSD: PSD vector
%   F: Freq vector
%   VLF, LF, HF: array containing VLF, LF, and HF freq limits
%   flagNormalize: option to normalize PSD to max(PSD)
%Output:
%
%Usage:
%   
%
%   Modified from Gary Clifford's ECG Toolbox: calc_lfhf.m   

    if nargin<6
       flagNorm=false;
    end
    
    %normalize PSD if needed
    if flagNorm
        PSD=PSD/max(PSD);
    end

    % find the indexes corresponding to the VLF, LF, and HF bands
    iVLF= (F>=VLF(1)) & (F<=VLF(2));
    iLF = (F>=LF(1)) & (F<=LF(2));
    iHF = (F>=HF(1)) & (F<=HF(2));
      
    %Find peaks
      %VLF Peak
      tmpF=F(iVLF);
      tmppsd=PSD(iVLF);
      [pks,ipks] = zipeaks(tmppsd);
      if ~isempty(pks)
        [~, i]=max(pks);        
        peakVLF=tmpF(ipks(i));
      else
        [~, i]=max(tmppsd);
        peakVLF=tmpF(i);
      end
      %LF Peak
      tmpF=F(iLF);
      tmppsd=PSD(iLF);
      [pks,ipks] = zipeaks(tmppsd);
      if ~isempty(pks)
        [~, i]=max(pks);
        peakLF=tmpF(ipks(i));
      else
        [~, i]=max(tmppsd);
        peakLF=tmpF(i);
      end
      %HF Peak
      tmpF=F(iHF);
      tmppsd=PSD(iHF);
      [pks,ipks] = zipeaks(tmppsd);
      if ~isempty(pks)
        [~, i]=max(pks);        
        peakHF=tmpF(ipks(i));
      else
        [~, i]=max(tmppsd);
        peakHF=tmpF(i);
      end 
      
    % calculate raw areas (power under curve), within the freq bands (ms^2)
    aVLF=trapz(F(iVLF),PSD(iVLF));
    aLF=trapz(F(iLF),PSD(iLF));
    aHF=trapz(F(iHF),PSD(iHF));
    aTotal=aVLF+aLF+aHF;
    logVLF = log(aVLF);
    logLF = log(aLF);
    logHF = log(aHF);

        
    %calculate areas relative to the total area (%)
    pVLF=(aVLF/aTotal)*100;
    pLF=(aLF/aTotal)*100;
    pHF=(aHF/aTotal)*100;
    
    %calculate normalized areas (relative to HF+LF, n.u.)
    nLF=aLF/(aLF+aHF)*100;
    nHF=aHF/(aLF+aHF)*100;
    
    %calculate LF/HF ratio
    lfhf =aLF/aHF;
            
    %create output structure
    if flagNorm
        output.aVLF=round(aVLF*1000)/1000;
        output.aLF=round(aLF*1000)/1000;
        output.aHF=round(aHF*1000)/1000;
        output.aTotal=round(aTotal*1000)/1000;
    else
        output.aVLF=round(aVLF,4); % round
        output.aLF=round(aLF,4);
        output.aHF=round(aHF,4);
        output.aTotal=round(aTotal,4);
    end    
    output.logVLF=round(logVLF,4);
    output.logLF=round(logLF,4);
    output.logHF=round(logHF,4);
    output.pVLF=round(pVLF,4);
    output.pLF=round(pLF,4);
    output.pHF=round(pHF,4);
    output.nLF=round(nLF,4);
    output.nHF=round(nHF,4);
    output.LFHF=round(lfhf,4);
    output.peakVLF=round(peakVLF(1),4);
    output.peakLF=round(peakLF(1),4);
    output.peakHF=round(peakHF(1),4);
end

function [pks, locs]=zipeaks(y)
%zippeaks: finds local maxima of input signal y
%Usage:  peak=zipeaks(y);
%Returns 2x(number of maxima) array
%pks = value at maximum
%locs = index value for maximum
%
%Reference:  2009, George Zipfel (Mathworks File Exchange #24797)

%check dimentions
if isempty(y)
    pks=[]; locs=[];
    return
end
[rows, cols] = size(y);
if cols==1 && rows>1 %all data in 1st col
    y=y';
elseif cols==1 && rows==1 
    pks=[]; locs=[];
    return    
end         
    
%Find locations of local maxima
%yD=1 at maxima, yD=0 otherwise, end point maxima excluded
    N=length(y)-2;
    yD=[0 (sign(sign(y(2:N+1)-y(3:N+2))-sign(y(1:N)-y(2:N+1))-.1)+1) 0];
%Indices of maxima and corresponding values of y
    Y=logical(yD);
    I=1:length(Y);
    locs=I(Y);
    pks=y(Y);
end
