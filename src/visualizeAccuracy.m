clear variables
close all
clc

methods={'hdmr'                ,'HDMR'    ,'o',  [0      0      1     ],...
         'chi2'                ,'Chi2'    ,'+',  [1      0      0     ],... 
         'svmrfe'              ,'SVM-RFE' ,'*',  [0      1      0     ],...
         'relieff'             ,'ReliefF' ,'.',  [0      0      0.1724],...
         'infogain'            ,'IG'      ,'x',  [1      0.1034 0.7241],...
         'fisher'              ,'Fisher'  ,'s',  [1      0.8276 0     ],...
         'mrmr'                ,'mRMR'    ,'d',  [0      0.3448 0     ],...
         'jmi'                 ,'JMI'     ,'^',  [0.5172 0.5172 1     ]};   
     
dats={'INDIANPINES','BOTSWANA','SUNDIKEN'};
classifiers={'svm','bayes','tree'};

legend_size=18;
labelsize=24;
ticksize=12;

for m=1:length(classifiers);
    for i=1:length(dats)
        data=dats{i};
        
        classifier=classifiers{m};
        figure('Visible','on')
        leginfo={};

        for j=1:length(methods)/4
            method    = methods{(j-1)*4+1};
            methodname= methods{(j-1)*4+2};
            marker    = methods{(j-1)*4+3};
            color     = methods{(j-1)*4+4};
            resfile=sprintf('../results/%s_accuracy_%s_%s.mat',data,method,classifier);
            if exist(resfile,'file') == 2
                load(resfile)
                plot(frange,mean(accuracies(:,:)),'Color',color,'Marker',marker,'LineWidth',1);
                leginfo{end+1} = methodname;
            else
                fprintf('%s doesnt exists\n',resfile);
                plot(5,1,'Color',color);
                leginfo{end+1}=method;
            end
            hold on
        end
        
        h_legend=legend(leginfo,'Location','SouthEast','Interpreter','none');
        set(h_legend,'FontSize',legend_size);        
        set(gcf,'color','w');
        xlabel('# Features','FontSize',labelsize);
        ylabel('Classification Accuracy','FontSize',labelsize);
        grid on
        pdffile=sprintf('../figures/%s_accuracy_%s.pdf',data,classifier);
        fprintf('Creating %s\n',pdffile);
        export_fig(pdffile);
    end
end