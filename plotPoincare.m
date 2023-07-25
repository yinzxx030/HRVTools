function plotPoincare(UIAxesPoincare,ibi,hrv)
            
    %create poincare plot
    x=ibi(1:end-1,2);
    y=ibi(2:end,2);
    dx=abs(max(x)-min(x))*0.05; xlim=[min(x)-dx max(x)+dx];
    dy=abs(max(y)-min(y))*0.05; ylim=[min(y)-dy max(y)+dy]; 
    plot(UIAxesPoincare,x,y,'o','MarkerSize',3)
    
    %calculate new x axis at 45 deg counterclockwise. new x axis = a
    a=x./cos(pi/4);     %translate x to a
%         b=sin(pi/4)*(y-x);  %tranlsate x,y to b
    ca=mean(a);         %get the center of values along the 'a' axis
    %tranlsate center to xyz
    [cx, cy, ~]=deal(ca*cos(pi/4),ca*sin(pi/4),0); 
    
    hold(UIAxesPoincare,'on');   
    %draw y(x)=x (CD2 axis)
    hEz=ezplot(UIAxesPoincare,'x',[xlim(1),xlim(2),ylim(1),ylim(2)]);
    set(hEz,'color','black')
    %draw y(x)=-x+2cx (CD2 axis)
    eqn=['-x+' num2str(2*cx)];
    hEz2=ezplot(UIAxesPoincare,eqn,[xlim(1),xlim(2),ylim(1),ylim(2)]);
    set(hEz2,'color','black')
           
    %plot ellipse
    width=hrv.SD2/1000; %convert to s
    height=hrv.SD1/1000; %convert to s
    hE = ellipsedraw(UIAxesPoincare,width,height,cx,cy,pi/4,'-r');
    set(hE,'linewidth', 2)                
    %plot SD2 inside of ellipse
    lsd2=line([cx-width cx+width],[cy cy],'color','r', ...
        'Parent',UIAxesPoincare, 'linewidth',2);
    rotate(lsd2,[0 0 1],45,[cx cy 0])
    %plot SD1 inside of ellipse
    lsd1=line([cx cx],[cy-height cy+height],'color','r', ...
        'Parent',UIAxesPoincare, 'linewidth',2);
    rotate(lsd1,[0 0 1],45,[cx cy 0])        
    
    hold(UIAxesPoincare,'off');
    
  %  set(UIAxesPoincare,'FontSize',7);
   % title(eqn,'FontSize',10)
%         
%         a = get(gca,'XTickLabel');
%         set(gca,'XTickLabel',a,'FontSize',7)
%         
    xlabel(UIAxesPoincare,'IBI_N (s)','FontSize',9);
    ylabel(UIAxesPoincare,'IBI_{N+1} (s)','FontSize',9);
    h.text.p(1,1)=text(.35,.95,'SD1:','Parent',UIAxesPoincare, ...
        'Units','normalized','Fontsize',6);
    h.text.p(2,1)=text(.35,.9,'SD2:','Parent',UIAxesPoincare, ...
        'Units','normalized','Fontsize',6);
    h.text.p(1,2)=text(.48,.95,...
        [sprintf('%0.1f',hrv.SD1) ' ms'],...
        'Parent',UIAxesPoincare,'Units','normalized','Fontsize',8);
    h.text.p(2,2)=text(.48,.9,...
        [sprintf('%0.1f',hrv.SD2) ' ms'],...
        'Parent',UIAxesPoincare,'Units','normalized','Fontsize',8);
    
    axis(UIAxesPoincare,'square')
    %set event to copy fig on dblclick
    set(UIAxesPoincare,'ButtonDownFcn',@copyAxes);
    
end