function [TDoutput, FDoutput, PDoutput, NDoutput, TFoutput] = hrvAnalyse(parameter, IBI, tag)
%% HVR分析
    % 判断IBI是否为空
    if isempty(IBI)
        [TDoutput, FDoutput, PDoutput, NDoutput, TFoutput] = hrvAnalyseNone();
    else
        %% 手动校正+自动校正
        %若是手动校正则去除IBI异常值，用均值替代
        if strcmp(tag, 'corr')
            m = mean(IBI(:,2));
            idx = IBI(:,2)>2*m;
            IBI(idx,2) = m; 
        end
        %% 时域分析
        TDoutput = timeDomainHRV(IBI, parameter.SDNNiIndex, parameter.pNNxIndex);
        
        %% 频域分析
        % FFT
        FDoutput.welch = freqDomainHRV(IBI, parameter.welch.VLF, parameter.welch.LF,...
            parameter.welch.HF, parameter.ar.AR_order, parameter.welch.window,...
            parameter.welch.noverlap, parameter.welch.nfft, parameter.welch.fs, 'welch');
        % AR
        FDoutput.ar = freqDomainHRV(IBI, parameter.ar.VLF, parameter.ar.LF,...
            parameter.ar.HF, parameter.ar.AR_order, parameter.welch.window,...
            parameter.welch.noverlap, parameter.ar.nfft, parameter.ar.fs, 'ar');
    
        %% 非线性分析
        PDoutput = poincareHRV(IBI);
        NDoutput = nonlinearHRV(IBI, parameter.m, parameter.r, parameter.n1,...
            parameter.n2, parameter.breakpoint);

        %% 时频分析
        TFoutput = timeFreqHRV(IBI, IBI, parameter.welch.VLF, parameter.welch.LF,...
            parameter.welch.HF, parameter.ar.AR_order, parameter.TF.window,...
            parameter.TF.noverlap, parameter.welch.nfft, parameter.welch.fs, ...
            {'ar','lomb','wavelet'});
    end
end

function [TDoutput, FDoutput, PDoutput, NDoutput, TFoutput] = hrvAnalyseNone()
%% 若IBI为空，则返回空的HRV结果
    TDoutput.mean=0;
    TDoutput.SDNN=0;
    TDoutput.meanHR=0;
    TDoutput.sdHR=0;
    TDoutput.RMSSD=0;
    TDoutput.NNx=0;
    TDoutput.pNNx=0;
    TDoutput.SDNNi=0;
    TDoutput.HRVTi=0;
    TDoutput.TINN=0;
    TDoutput.SI = 0;
    
    FDoutput.welch.hrv.peakVLF=0;
    FDoutput.welch.hrv.peakLF=0;
    FDoutput.welch.hrv.peakHF=0;
    FDoutput.welch.hrv.aVLF=0;
    FDoutput.welch.hrv.aLF=0;
    FDoutput.welch.hrv.aHF=0;
    FDoutput.welch.hrv.pVLF=0;
    FDoutput.welch.hrv.pLF=0;
    FDoutput.welch.hrv.pHF=0;
    FDoutput.welch.hrv.nLF=0;
    FDoutput.welch.hrv.nHF=0;
    FDoutput.welch.hrv.LFHF=0;
    
    FDoutput.ar.hrv.peakVLF=0;
    FDoutput.ar.hrv.peakLF=0;
    FDoutput.ar.hrv.peakHF=0;
    FDoutput.ar.hrv.aVLF=0;
    FDoutput.ar.hrv.aLF=0;
    FDoutput.ar.hrv.aHF=0;
    FDoutput.ar.hrv.pVLF=0;
    FDoutput.ar.hrv.pLF=0;
    FDoutput.ar.hrv.pHF=0;
    FDoutput.ar.hrv.nLF=0;
    FDoutput.ar.hrv.nHF=0;
    FDoutput.ar.hrv.LFHF=0;
    
    PDoutput.SD1=0;
    PDoutput.SD2=0;
    PDoutput.SDratio=0;
    NDoutput.sampen=0;
    NDoutput.dfa.alpha=0;
    NDoutput.dfa.alpha1=0;
    NDoutput.dfa.alpha2=0;

    TFoutput.ar.t=0;
    TFoutput.ar.psd=0;
    TFoutput.ar.f=0;
    TFoutput.ar.hrv.aVLF=0;
    TFoutput.ar.hrv.aLF=0;
    TFoutput.ar.hrv.aHF=0;
    TFoutput.ar.hrv.aTotal=0;
    TFoutput.ar.hrv.pVLF=0;
    TFoutput.ar.hrv.pLF=0;
    TFoutput.ar.hrv.pHF=0;
    TFoutput.ar.hrv.nLF=0;
    TFoutput.ar.hrv.nHF=0;
    TFoutput.ar.hrv.LFHF=0;
    TFoutput.ar.hrv.peakVLF=0;
    TFoutput.ar.hrv.peakLF=0;
    TFoutput.ar.hrv.peakHF=0;
    TFoutput.lomb.t=0;
    TFoutput.lomb.psd=0;
    TFoutput.lomb.f=0;
    TFoutput.lomb.hrv.aVLF=0;
    TFoutput.lomb.hrv.aLF=0;
    TFoutput.lomb.hrv.aHF=0;
    TFoutput.lomb.hrv.aTotal=0;
    TFoutput.lomb.hrv.pVLF=0;
    TFoutput.lomb.hrv.pLF=0;
    TFoutput.lomb.hrv.pHF=0;
    TFoutput.lomb.hrv.nLF=0;
    TFoutput.lomb.hrv.nHF=0;
    TFoutput.lomb.hrv.LFHF=0;
    TFoutput.lomb.hrv.peakVLF=0;
    TFoutput.lomb.hrv.peakLF=0;
    TFoutput.lomb.hrv.peakHF=0;
    TFoutput.wav.t=0;
    TFoutput.wav.psd=0;
    TFoutput.wav.f=0;
    TFoutput.wav.hrv.aVLF=0;
    TFoutput.wav.hrv.aLF=0;
    TFoutput.wav.hrv.aHF=0;
    TFoutput.wav.hrv.aTotal=0;
    TFoutput.wav.hrv.pVLF=0;
    TFoutput.wav.hrv.pLF=0;
    TFoutput.wav.hrv.pHF=0;
    TFoutput.wav.hrv.nLF=0;
    TFoutput.wav.hrv.nHF=0;
    TFoutput.wav.hrv.LFHF=0;
    TFoutput.wav.hrv.peakVLF=0;
    TFoutput.wav.hrv.peakLF=0;
    TFoutput.wav.hrv.peakHF=0;

end