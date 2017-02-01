clear variables
close all
clc


methods={'hdmr'         ,'HDMR'           ,[0      0      1     ],...
         'chi2'         ,'Chi2'           ,[1      0      0     ],... 
         'svmrfe'       ,'SVM-RFE'        ,[0      1      0     ],...
         'relieff'      ,'ReliefF'        ,[0      0      0.1724],...
         'infogain'     ,'IG'             ,[1      0.1034 0.7241],...
         'fisher'       ,'Fisher'         ,[1      0.8276 0     ],...
         'mrmr'         ,'mRMR'           ,[0      0.3448 0     ],...
         'jmi'          ,'JMI'            ,[0.5172 0.5172 1     ]};
     
dats={'INDIANPINES','BOTSWANA','SUNDIKEN'};
classifiers={'svm','bayes','tree'};
markers={'o','diamond','square'};
classcol=[66 21 117;207 208 229;236 146 50]/255;

figure('Position',[0 0 700 800]);
for j=1:length(methods)/3
    plot([1 9],[j j],'k');
    hold on;
end

for m=1:length(classifiers);
    for i=1:length(dats)
        accdata = [];
        for j=1:length(methods)/3
            method=methods{1+(j-1)*3};
            metnam=methods{2+(j-1)*3};
            metcol=methods{3+(j-1)*3};
            classifier=classifiers{m};
            data=dats{i};
            resfile=sprintf('../results/%s_accuracy_%s_%s.mat',data,method,classifier);
            load(resfile)
            accdata=[accdata; mean(accuracies)];
        end
        [n_methods,n_features_fold]=size(accdata);
        maxacc=max(accdata(:));
        for j=1:length(methods)/3
                        method=methods{1+(j-1)*3};
            metnam=methods{2+(j-1)*3};
            metcol=methods{3+(j-1)*3};
             psize = sum(abs(accdata(j,:)-repmat(maxacc,1,n_features_fold)));
             fprintf('%25s %20s %20s %8.5f\n',method,classifier,data,psize);
            plot((m-1)*length(classifiers)+i,j,...
                'Marker',markers{m},'MarkerSize',15*sqrt(psize),...
                'MarkerFaceColor',classcol(m,:),...
                'MarkerEdgeColor','k');
            hold on
        end
    end
end


set(gcf,'color','w');
set(gca,'XTick',1:9);
set(gca,'XTickLabel',{'I','B','S','I','B','S','I','B','S'},'FontSize',18);
set(gca,'YTick',1:length(methods)/3);
set(gca,'YTickLabel',methods(2:3:end),'FontSize',18);
xlim([0 10]);
ylim([0 9]);
export_fig('../figures/accuracyAllinOne.pdf')
