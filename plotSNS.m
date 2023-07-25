function plotSNS(appinfo)
x = [-5:0.1:5]; y = normpdf(x, 0, 1)*0.5+0.02;
summermap = colormap(summer(length(x)));
pinkmap = colormap(pink(length(x)));

%计算PNS、SNS结果值
[~, SNS] = calculatePNS_SNS(appinfo.TDoutput, appinfo.PDoutput);

SNS = round(SNS, 2);

hold on

for i = 1:40
    area(x(101-i: 102-i), y(101-i: 102-i) ,'FaceColor',pinkmap(i+30, :),'FaceAlpha',0.7,'EdgeColor','none'); %SNS左边[5,1]
end

for i = 1:60
    area(x(i: i+1), y(i: i+1) ,'FaceColor',summermap(i, :),'FaceAlpha',0.6,'EdgeColor','none');  %SNS右边[1,-5] 1~61项
end

%绘制正态分布图
plot(x, y,'Color',[0.5 0.5 0.5]);

%绘制结果线
plot([SNS SNS], [0 0.25],'Color','k' , 'LineWidth', 1.5); xlim([-5, 5])
yticks([]);
xticks([-5,-4,-3,-2,-1,0,1,2,3,4,5]);

title(['交感指数=',num2str(SNS)],'FontSize', 10);


hold off

end