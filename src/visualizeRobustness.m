% 
% Requirements:
% 1. export_fig package
% 2. subaxis package


clear variables
close all
clc

methods={'hdmr'      ,'HDMR'           ,[0      0      1     ],...
         'chi2'      ,'Chi2'           ,[1      0      0     ],... 
         'svmrfe'    ,'SVM-RFE'        ,[0      1      0     ],...
         'relieff'   ,'ReliefF'        ,[0      0      0.1724],...
         'infogain'  ,'IG'             ,[1      0.1034 0.7241],...
         'fisher'    ,'Fisher'         ,[1      0.8276 0     ],...
         'mrmr'      ,'mRMR'           ,[0      0.3448 0     ],...
         'jmi'       ,'JMI'            ,[0.5172 0.5172 1     ]};
datasets   = {'INDIANPINES','BOTSWANA','SUNDIKEN'};
nfeatures  = [200          145        156];
topF=10;
leginfo={};
tonimato = @(a,b)  1 - (numel(a)+numel(b)-2*numel(intersect(a,b)))/(numel(a)+numel(b)-numel(intersect(a,b)));

for i=1:length(datasets)
    dataset=datasets{i};
    flen=nfeatures(i);
    
    figure('Visible','on','Position',[0 0 400 600]);
    for j=1:length(methods)/3
        fmap=zeros(flen,topF);        
        algorithm = methods{1+(j-1)*3};
        algorithmDisplay=methods{2+(j-1)*3};
        featfile=strcat(pwd,'/../results/',dataset,'_features_',algorithm,'.mat');
        if exist(featfile,'file') == 2
            feats=load(featfile);
            % I add 1, because python is zero-based
            feats.features=feats.features + 1;
            folds=size(feats.features,2);
            sssum=0;
            for k=1:folds
                features1=feats.features(1:topF,k);
                %topFeatures=feats.features(end-topF-1:end,k);
                if sum(features1) == 0
                    % Features haven't been determined yet
                    continue;
                end
                fmap(features1,k)=1;
                for k2=k+1:folds
                    features2=feats.features(1:topF,k2);
                    sssum = sssum + tonimato(features1,features2);
                end
            end
            ssavg = sssum/((folds*folds-folds)/2);
            fprintf('%20s %20s %8.3f\n',dataset,algorithmDisplay, ssavg);
        else
            ssavg=0.0;
        end
        
        subaxis(length(methods)/3,1,j,'SpacingVert',0);
        margin=round(flen/7);
        fmapextended = [fmap;zeros(margin,size(fmap,2))];
        imagesc(fmapextended'); colormap(flipud(gray));
        hold on
        
        text(flen+margin,1,sprintf('%3.1f',ssavg),'FontSize',20,...
            'HorizontalAlignment', 'right',...
            'VerticalAlignment','top','Color','k');
        
        ylabel(algorithmDisplay,'FontSize',12,...
            'Interpreter','None',...
            'Color',[162 68 10]/255);
        set(gca,'XTick',[],'YTick',[]);
        if j == 8 % JMI
            set(gca,'XTick',[1 flen],'FontSize',12);
        end
    end
    set(gcf,'color','w');
    xlabel('Feature Index','FontSize',12);
    pdffile=sprintf('../figures/%s_robustness.pdf',dataset);
    fprintf('Creating %s\n',pdffile);
    export_fig(pdffile);
    
end
