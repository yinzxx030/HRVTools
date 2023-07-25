function output=poincareHRV(ibi)
%poincareHRV(ibi) - calculates poincare HRV
%
%Inputs:    ibi = 2dim array containing [t (s),ibi (s)]
%           
%Outputs:   output is a structure containg HRV.


    %check inputs
    ibi(:,2)=ibi(:,2).*1000; %convert ibi to ms
    %assumes ibi units are seconds
    
%     if abs(range(ibi(:,2)))<50 %assume ibi units are seconds            
%             ibi(:,2)=ibi(:,2).*1000; %convert ibi to ms
%     end
%     if abs(range(diff(ibi(:,1))))>50 %assume time unites are ms
%         ibi(:,1)=ibi(:,1)./1000; %convert time to s
%     end

    sd=diff(ibi(:,2)); %successive differences
    rr=ibi(:,2);
    SD01 = 0.5*var(sd);
    SD1 = sqrt(SD01);
    sdrr = sqrt(mean(rr.^2)-mean(rr)^2);
    SD02 = 2*sdrr^2 - SD01;
    SD2 = sqrt(SD02);

%     SD1=sqrt( 0.5*std(sd)^2 );
%     SD2=sqrt( 2*(std(rr)^2) - (0.5*std(sd)^2) );
    
    %format decimal places
    output.SD1=round(SD1*10)/10; %ms
    output.SD2=round(SD2*10)/10; %ms
    output.SDratio=output.SD2/output.SD1;

end