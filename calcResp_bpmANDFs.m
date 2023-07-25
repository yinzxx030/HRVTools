function [breath_bpm, breath_fs] = calcResp_bpmANDFs(Respiration, Fs)

N = length(Respiration);

%-------------------------------呼吸次数检测--------------------------------
if ~isempty(Respiration)
if N< Fs*1500
    if N < Fs *300
        Respiration_filter = Respiration;
    elseif N < Fs *900
        Respiration_filter = Respiration((N-300*Fs+1):N,:);
    else
        Respiration_filter = Respiration(600*Fs+1:900*Fs);
    end
    NRes = length(Respiration_filter);
    index = 0;
    NN = linspace(1,NRes, NRes);
    for i = 1:NRes-1
        if sign(Respiration_filter(i))~=sign(Respiration_filter(i+1))
            index = index+1;
            NN(i) =0;
        end
        NN0= find(~NN);
        lengthNN0 = length(NN0);
    end
     for j = 1:lengthNN0-1
            judge = NN0(j+1)-NN0(j);
            if judge < Fs
                index =  index-1;
            end
     end
    breath_bpm = roundn(index/2*60*Fs/NRes,-1);
    breath_fs = roundn(breath_bpm/60,-2);
end


if N>Fs*1500
    if N<Fs*1800
        Respiration_filter1 = Respiration(600*Fs+1:900*Fs);
        NRes1 = length(Respiration_filter1);
        Respiration_filter2 = Respiration((end-300*Fs+1):end);
        NRes2 = length(Respiration_filter2);
    else
        Respiration_filter1 = Respiration(600*Fs+1:900*Fs);
        NRes1 = length(Respiration_filter1);
        Respiration_filter2 = Respiration(1500*Fs+1:1800*Fs);
        NRes2 = length(Respiration_filter2);   
    end
    index1 = 0;
    NN1 = linspace(1,NRes1, NRes1);
    for i = 1:NRes1-1
        if sign(Respiration_filter1(i))~=sign(Respiration_filter1(i+1))
            index1 = index1+1;
            NN1(i) = 0;
        end
        NN10 = find(~NN1);
        lengthNN10 = length(NN10);
    end
     for j = 1:lengthNN10-1
            judge = NN1(j+1)-NN1(j);
            if judge < Fs
                index1 =  index1-1;
            end
     end
    breath_bpm1 = roundn(index1/2*60*Fs/NRes1,-1);
    breath_fs1 = roundn(breath_bpm1/60,-2);
    index2 = 0;
    NN2 = linspace(1,NRes2, NRes2);
    for i = 1:NRes2-1
        if sign(Respiration_filter2(i))~=sign(Respiration_filter2(i+1))
            index2 = index2+1;
            NN2(i) = 0;
        end
        NN20 = find(~NN2);
        lengthNN20 = length(NN20);
     for j = 1:lengthNN20-1
            judge = NN2(j+1)-NN2(j);
            if judge < Fs
                index2 =  index2-1;
            end
     end
    end
    breath_bpm2 = roundn(index2/2*60*Fs/NRes2,-1);
    breath_fs2 = roundn(breath_bpm2/60,-2);

    BPM = [breath_bpm1, breath_bpm2];
    FS = [breath_fs1, breath_fs2];
    breath_bpm = mean(BPM);
    breath_fs = mean(FS);
end
else
    breath_bpm = [];
    breath_fs = [];
end