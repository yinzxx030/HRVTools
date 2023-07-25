function [PNS, SNS] = plotPNS(appinfo)
x = [-5:0.1:5]; y = normpdf(x, 0, 1)*0.5+0.02;
summermap = colormap(summer(length(x)));
pinkmap = colormap(pink(length(x)));

%计算PNS、SNS结果值
[PNS, SNS] = calculatePNS_SNS(appinfo.TDoutput, appinfo.PDoutput);
PNS = round(PNS, 2);
SNS = round(SNS, 2);
hold on


for i = 1:40
    area(x(i: i+1), y(i: i+1) ,'FaceColor',pinkmap(i+30, :),'FaceAlpha',0.7,'EdgeColor','none'); %PNS左边[-5,-1]

end

for i = 1:60
    area(x(40+i: i+41), y(40+i: i+41) ,'FaceColor',summermap(61-i, :),'FaceAlpha',0.6,'EdgeColor','none');  %PNS右边[-1,5]
end

%绘制正态分布图
plot(x, y,'Color',[0.5 0.5 0.5]);

%绘制结果线
plot([PNS PNS], [0 0.25],'Color','k', 'LineWidth', 1.5); xlim([-5, 5])

yticks([]);
xticks([-5,-4,-3,-2,-1,0,1,2,3,4,5]);

title(['副交感指数=',num2str(PNS)],'FontSize', 10);

hold off

end