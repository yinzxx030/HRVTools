function plotPoincare_aH(ibi,hrv)
            
    %create poincare plot
    x=ibi(1:end-1,2);
    y=ibi(2:end,2);
    dx=abs(max(x)-min(x))*0.05; xlim=[min(x)-dx max(x)+dx];
    dy=abs(max(y)-min(y))*0.05; ylim=[min(y)-dy max(y)+dy]; 
    plot(x,y,'o','MarkerSize',3)
    
    %calculate new x axis at 45 deg counterclockwise. new x axis = a
    a=x./cos(pi/4);     %translate x to a
%         b=sin(pi/4)*(y-x);  %tranlsate x,y to b
    ca=mean(a);         %get the center of values along the 'a' axis
    %tranlsate center to xyz
    [cx, cy, ~]=deal(ca*cos(pi/4),ca*sin(pi/4),0); 
    
    hold on
    %draw y(x)=x (CD2 axis)
    hEz=ezplot('x',[xlim(1),xlim(2),ylim(1),ylim(2)]);
    set(hEz,'color','black')
    %draw y(x)=-x+2cx (CD2 axis)
    eqn=['-x+' num2str(2*cx)];
    hEz2=ezplot(eqn,[xlim(1),xlim(2),ylim(1),ylim(2)]);
    set(hEz2,'color','black')
           
    %plot ellipse
    width=hrv.SD2/1000; %convert to s
    height=hrv.SD1/1000; %convert to s
    hE = ellipse_draw(width,height,cx,cy,pi/4,'-r');
    set(hE,'linewidth', 2)                
    %plot SD2 inside of ellipse
    lsd2=line([cx-width cx+width],[cy cy],'color','r', 'linewidth',2);
    rotate(lsd2,[0 0 1],45,[cx cy 0])
    %plot SD1 inside of ellipse
    lsd1=line([cx cx],[cy-height cy+height],'color','r', 'linewidth',2);
    rotate(lsd1,[0 0 1],45,[cx cy 0])        
    
    hold off
          
    xlabel('IBI_N (s)','FontSize',9);
    ylabel('IBI_{N+1} (s)','FontSize',9);
    
function hEllipse = ellipse_draw(a,b,x0,y0,phi,lineStyle)

theta = [-0.03:0.01:2*pi];

% Parametric equation of the ellipse
%----------------------------------------
 xe = a*cos(theta);
 ye = b*sin(theta);

% Coordinate transform 
%----------------------------------------
 X = cos(phi)*xe - sin(phi)*ye;
 Y = sin(phi)*xe + cos(phi)*ye;
 X = X + x0;
 Y = Y + y0;

% Plot the ellipse
%----------------------------------------
 hEllipse = plot(X,Y,lineStyle);
 
 
 %axis equal;
end
end