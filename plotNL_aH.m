function plotNL_aH(hrv,breakpoint)   
    %此函数用于绘制pdf报告
    %plot DFA
    x=log10(hrv.dfa.n); y=log10(hrv.dfa.F_n);
    plot(x,y,'.','MarkerSize',10)                
    
    ibreak=find(hrv.dfa.n==breakpoint);
    %short term fit
    lfit_a1=polyval(hrv.dfa.alpha1,x(1:ibreak));
    %long term fit
    lfit_a2=polyval(hrv.dfa.alpha2,x(ibreak+1:end));
    
    hold on
    plot(x(1:ibreak),lfit_a1,'r-', 'linewidth',2)
    plot(x(ibreak+1:end),lfit_a2,'g-','linewidth',2)
    
    hold off
    
    xrange=abs(max(x)-min(x)); xadd=xrange*0.06;
    xlim=[min(x)-xadd, max(x)+xadd];
    yrange=abs(max(y)-min(y)); yadd=yrange*0.06;
    ylim=[min(y)-yadd, max(y)+yadd];
    set(gca,'xlim',xlim,'ylim',ylim,'FontSize',7)
    title('DFA','FontSize',10)
    xlabel('log_{10}n','FontSize',8)
    ylabel('log_{10}F(n)','FontSize',8)

    
end