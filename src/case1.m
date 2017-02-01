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
    scatter(s1,s1./so,200*a.^4,...
        gcolors,'filled',...
        'MarkerEdgeColor','k',...
        'Marker',markers{iM});
    
    hold on
end
box on
grid on
xlabel('Sensitivity index: S_1','FontSize',14);
ylabel('How many times S_1 is larger than the others','FontSize',14)
set(gca,'yscale','log')
%set(gca,'xscale','log')
%xlim([min(s1all) 1])
%set(gca,'XTick',[0.1 1],'YTick',[0.1 1]);
[hleg, hobj, hout, mout]=legend('M=100','M=1,000','M=10,000','Location','NorthWest');
set(hleg,'FontSize',16);
hobj(4).Children.MarkerSize = 10;
hobj(4).Children.MarkerFaceColor = colors(1,:);
hobj(5).Children.MarkerSize = 10;
hobj(5).Children.MarkerFaceColor = colors(2,:);
hobj(6).Children.MarkerSize = 10;
hobj(6).Children.MarkerFaceColor = colors(3,:);

set(gcf,'color','w');
export_fig('../figures/case1ChoosingM.pdf');