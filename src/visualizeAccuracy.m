clear variables
close all
clc

methods={'hdmr'           ,'HDMR'    ,'o',  [0      0      1     ],...
    'chi2'                ,'Chi2'    ,'+',  [1      0      0     ],...
    'svmrfe'              ,'SVM-RFE' ,'*',  [0      1      0     ],...
    'relieff'             ,'ReliefF' ,'.',  [0      0      0.1724],...
    'infogain'            ,'IG'      ,'x',  [1      0.1034 0.7241],...
    'fisher'              ,'Fisher'  ,'s',  [1      0.8276 0     ],...
    'mrmr'                ,'mRMR'    ,'d',  [0      0.3448 0     ],...
    'jmi'                 ,'JMI'     ,'^',  [0.5172 0.5172 1     ]};

dats={'INDIANPINES','BOTSWANA','SUNDIKEN'};
datanames = {'Indian Pines','Botswana','Sundiken'};
classifiers={'svm','bayes','tree'};
classifiernames={'SVM','Bayes','CART'};

legend_size=6;
labelsize=6;
ticksize=6;

for m=1:length(classifiers);
    for i=1:length(dats)
        data=dats{i};
        classifiername=classifiernames{m};
        dataname = datanames{i};
        
        classifier=classifiers{m};
        %figure('Visible','on')
        figure('PaperUnits','points','Position',[0 0 172 70]);
        
        leginfo={};
        ymin = Inf;
        ymax = -Inf;
        
        for j=1:length(methods)/4
            method    = methods{(j-1)*4+1};
            methodname= methods{(j-1)*4+2};
            marker    = methods{(j-1)*4+3};
            color     = methods{(j-1)*4+4};
            resfile=sprintf('../results/%s_accuracy_%s_%s.mat',data,method,classifier);
            if exist(resfile,'file') == 2
                load(resfile)
                plot(frange,mean(accuracies(:,:)),'Color',color,...
                    'Marker',marker,'MarkerFaceColor',color,'Markers',2,'LineWidth',1);
                leginfo{end+1} = methodname;
                
                if max(mean(accuracies(:,:))) > ymax
                    ymax = max(mean(accuracies(:,:))) ;
                end
                if min(mean(accuracies(:,:))) < ymin
                    ymin = min(mean(accuracies(:,:)));
                end
            else
                fprintf('%s doesnt exists\n',resfile);
                plot(5,1,'Color',color);
                leginfo{end+1}=method;
            end
            hold on
        end
        
        %h_legend=legend(leginfo,'Location','SouthEast','Interpreter','none');
        %set(h_legend,'FontSize',legend_size);
        set(gcf,'color','w');
        set(gca,'FontSize',6);
        %xlabel('# Features','FontSize',labelsize);
        %ylabel('Classification Accuracy','FontSize',labelsize);
        xlim([frange(1) frange(end)]);
        ylim([ymin ymax]);
        pdffile=sprintf('../figures/%s_accuracy_%s.pdf',data,classifier);
        fprintf('Creating %s\n',pdffile);
        if strcmp(classifier,'svm') || strcmp(classifier,'bayes')
            set(gca,'XTick',[]);
        end
        set(gca,'YTick',[ymin ymax],...
            'YTickLabel',{sprintf('%3.1f',ymin),sprintf('%3.1f',ymax)});
        
        text(double(frange(1)-5*100/(frange(end)-frange(1))),0.5*(ymin+ymax),'accuracy',...
            'Rotation',90,'HorizontalAlignment','center',...
            'VerticalAlignment','bottom','FontSize',8);
        text(double(frange(end)-frange(1))/2,ymin,...
            sprintf('%s/%s',dataname,classifiername),...
            'VerticalAlignment','bottom','FontSize',10,...
            'HorizontalAlignment','center',...
            'FontName','Times');
        % Trimming the whitespaces around the edges
%         ax = gca;
%         outerpos = ax.OuterPosition;
%         ti = ax.TightInset;
%         left = outerpos(1) + ti(1);
%         bottom = outerpos(2) + ti(2);
%         ax_width = outerpos(3) - ti(1) - ti(3);
%         ax_height = outerpos(4) - ti(2) - ti(4);
%         ax.Position = [left bottom ax_width ax_height];
        export_fig(pdffile);
    end
end