function plotPSD(aH,F,PSD,VLF,LF,HF,limX,limY)

    color.vlf=[.5 .5 1];    %vlf color
    color.lf=[.7 .5 1];     %lf color
    color.hf=[.5 1 1];      %hf color

    % find the indexes corresponding to the VLF, LF, and HF bands
    iVLF= find( (F>=VLF(1)) & (F<VLF(2)) );
    iLF = find( (F>=LF(1)) & (F<LF(2)) );
    iHF = find( (F>=HF(1)) & (F<HF(2)) );

    %plot area under PSD curve
    area(aH,F(:),PSD(:),'FaceColor',[.8 .8 .8]);        
    hold(aH);
    area(aH,F(iVLF(1):iVLF(end)+1),PSD(iVLF(1):iVLF(end)+1), ...
        'FaceColor',color.vlf);
    area(aH,F(iLF(1):iLF(end)+1),PSD(iLF(1):iLF(end)+1), ...
        'FaceColor',color.lf);
    area(aH,F(iHF(1):iHF(end)+1),PSD(iHF(1):iHF(end)+1), ...
        'FaceColor',color.hf);
    
    if ~isempty(limX)
        set(aH,'xlim',limX)
    else
        limX=[min(F) max(F)];
    end
    if ~isempty(limY)
        set(aH,'ylim',limY)
    else
        limY=[min(PSD) max(PSD)];
    end
    
    %draw vertical lines around freq bands
    plot(aH,[VLF(2) VLF(2)],[limY(1) limY(2)], 'r');
    plot(aH,[LF(2) LF(2)],[limY(1) limY(2)], 'r');
    plot(aH,[HF(2) HF(2)],[limY(1) limY(2)], 'r');
   
    hold(aH)
        
end