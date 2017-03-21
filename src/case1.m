clear variables
close all
clc

load('case1.mat')

nall=results(:,1);
mall=results(:,2);
Mall=results(:,3);
aall=results(:,4);
s1all=results(:,5);
s1rall=results(:,6);
soall=results(:,7);

figure('PaperUnits','points','Position',[0 0 240 150]);

colors = [0 0 1;1 0 0;0 1 0;];
markers = {'o','d','s'};
Mu = [100,1000,10000];
for iM = 1:numel(Mu)
    M=Mu(iM);
    n = nall(Mall==M);
    s1 = s1all(Mall==M);
    s1r = s1rall(Mall==M);
    so=soall(Mall==M);
    a = aall(Mall==M);
    
    gcolors=repmat(colors(iM,:),numel(n),1);
    gcolors=gcolors.*repmat((n-n(end))/(n(1)-n(end)),1,3);
    scatter(s1,s1./so,50*a.^4,...
        gcolors,'filled',...
        'MarkerEdgeColor','k',...
        'Marker',markers{iM});
    
    hold on
end
box on
grid on
xlabel('Sensitivity index: S_1','FontSize',8);
ylabel('$S_1/(\sum S_i - S_1)$','FontSize',8,'Interpreter','latex')
set(gca,'yscale','log')
%set(gca,'xscale','log')
%xlim([min(s1all) 1])
%set(gca,'XTick',[0.1 1],'YTick',[0.1 1]);
%[hleg, hobj, hout, mout]=legend('$M=10^2$','$M=10^3$','$M=10^4$','Location','NorthWest');
hleg=legend('$M=10^2$','$M=10^3$','$M=10^4$','Location','NorthWest');

set(hleg,'FontSize',8);
set(hleg,'Interpreter','latex');
% hobj(4).Children.MarkerSize = 8;
% hobj(4).Children.MarkerFaceColor = colors(1,:);
% hobj(5).Children.MarkerSize = 8;
% hobj(5).Children.MarkerFaceColor = colors(2,:);
% hobj(6).Children.MarkerSize = 8;
% hobj(6).Children.MarkerFaceColor = colors(3,:);

ylim([0.1 10^6]);
xlim([0 0.9]);
set(gcf,'color','w');
set(gca,'FontSize',8);

% Removing white space around the figure
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset;
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];

export_fig('../figures/case1ChoosingM.pdf');