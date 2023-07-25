function plotPSD_aH(F,PSD,VLF,LF,HF)
%去除绘图坐标区，用于绘制PDF
    color.vlf=[.5 .5 1];    %vlf color
    color.lf=[.7 .5 1];     %lf color
    color.hf=[.5 1 1];      %hf color

    % find the indexes corresponding to the VLF, LF, and HF bands
    iVLF= find( (F>=VLF(1)) & (F<VLF(2)) );
    iLF = find( (F>=LF(1)) & (F<LF(2)) );
    iHF = find( (F>=HF(1)) & (F<HF(2)) );

    %plot area under PSD curve
    area(F(:),PSD(:),'FaceColor',[.8 .8 .8]);        
    hold on;
    area(F(iVLF(1):iVLF(end)+1),PSD(iVLF(1):iVLF(end)+1), ...
        'FaceColor',color.vlf);
    area(F(iLF(1):iLF(end)+1),PSD(iLF(1):iLF(end)+1), ...
        'FaceColor',color.lf);
    area(F(iHF(1):iHF(end)+1),PSD(iHF(1):iHF(end)+1), ...
        'FaceColor',color.hf);
    
    axis([0 0.6 min(PSD) max(PSD)]);
%     if ~isempty(limX)
%         set('xlim',limX)
%     else
%         limX=[min(F) max(F)];
%     end
%     if ~isempty(limY)
%         set('ylim',limY)
%     else
        limY=[min(PSD) max(PSD)];
%     end
    
    %draw vertical lines around freq bands
    plot([VLF(2) VLF(2)],[limY(1) limY(2)], 'r');
    plot([LF(2) LF(2)],[limY(1) limY(2)], 'r');
    plot([HF(2) HF(2)],[limY(1) limY(2)], 'r');

        
end