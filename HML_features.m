% This should use just the hourly (or 3 hours) data (csv) at high-medium and low
% wind speeds. Calculate a load of features (see below) and see whether
% we can tell the difference in the way the tree moves.

% Potential features: SSA, Catch22, fo, slope (# peaks, different slopes etc)

% NOTE: I could add extra data to this analysis. Specifically AB, TJ_MY, DS
% and probably others

% This script loads in the tree motion data from csv and calculates Catch22 
% (and other) features. Then does some ordination and some correlation.

%% Load in the data and calculate features
%load('C:\Users\tobyd\Documents\MATLAB\TreeMotion_Analysis\Save_features\TT_HML.mat')
good_rows=find(TT.L_discard==0);
dataPath='C:\Users\tobyd\Documents\Data\TreeMotion_Data\OrganizedData\1hr\';
name_in='sh';
[table_sh, names] = calculate_features_fn7(dataPath,TT,good_rows,name_in);

%%
good_rows=find(TT.L_discard==0 & TT.L_HML==1);
dataPath='C:\Users\tobyd\Documents\Data\TreeMotion_Data\OrganizedData\1hr\med\';
name_in='sm';
[table_sm] = calculate_features_fn7(dataPath,TT,good_rows,name_in);

good_rows=find(TT.L_discard==0 & TT.L_HML==1);
dataPath='C:\Users\tobyd\Documents\Data\TreeMotion_Data\OrganizedData\1hr\low\';
name_in='sl';
[table_sl] = calculate_features_fn7(dataPath,TT,good_rows,name_in);
%%
good_rows=find(TT.L_discard==0 & TT.L_SW==1);
dataPath='C:\Users\tobyd\Documents\Data\TreeMotion_Data\OrganizedData\Winter_1hr\';
name_in='wh';
[table_wh] = calculate_features_fn7(dataPath,TT,good_rows,name_in);


%%
mat2clip(table_sh.Properties.VariableNames)
%%
mat2clip(table2array(table_sl))



%% Filter features
load('C:\Users\tobyd\Documents\MATLAB\TreeMotion_Analysis\Save_features\table_sm.mat')
load('C:\Users\tobyd\Documents\MATLAB\TreeMotion_Analysis\Save_features\table_sh.mat')
load('C:\Users\tobyd\Documents\MATLAB\TreeMotion_Analysis\Save_features\table_sl.mat')
load('C:\Users\tobyd\Documents\MATLAB\TreeMotion_Analysis\Save_features\TT.mat')
features_hml=table2array(cat(2,table_sh,table_sm,table_sl));
image(100*isnan(features_hml))
dark2=brewermap(8,'dark2');
%% Test the features
for col=1:26
    subplot(1,2,1)
    plot(features_hml(:,col))
    title(num2str(col))
    hold on
    subplot(1,2,2)
    hist(features_hml(:,col)); hold off
    pause
end

%% Log transform features
cols_log=[3 4 8 9 10 13 21];
[features_hml_log] = log_transform_features(features_hml,cols_log,26,6);


%% Filter cols
image(100*isnan(features_hml_log))
colnan=sum(isnan(features_hml_log),1);
scatter(1:156,colnan,'x'); grid on
% delete cols 10, 23, 24
features_hml_log_lesscols=delete_cols(features_hml_log,[10 23 24],26,6);
% so there is 48 in each.

%% Filter rows
rownan=sum(isnan(features_hml_log_lesscols),2);
scatter(1:195,rownan,'x'); grid on

% there are no bad columns for summer / winter, just work with good rows
TT_HML=TT(rownan==0,:);
features_hml_log_lessrows=features_hml_log_lesscols(rownan==0,:);


%% centre and scale features
features_hml_log_less_ztrans=nan(size(features_hml_log_lessrows));
sh_std=  std(features_hml_log_lessrows(:,1:46),0,1);
sh_mean=mean(features_hml_log_lessrows(:,1:46),1);
features_hml_log_less_ztrans(:,1:46)=(features_hml_log_lessrows(:,1:46)-sh_mean)./sh_std; 
features_hml_log_less_ztrans(:,47:92)=(features_hml_log_lessrows(:,47:92)-sh_mean)./sh_std;
features_hml_log_less_ztrans(:,93:end)=(features_hml_log_lessrows(:,93:end)-sh_mean)./sh_std;



%% Test the features
for col=1:144
    subplot(1,2,1)
    hist(features_hml_log_lessrows(:,col)); hold off
    title(num2str(col))
    %hold on
    subplot(1,2,2)
    hist(features_hml_log_lessrows(:,col)); hold off
    pause
end

%% PCA of hml separately

subplot(3,2,1)
[h,coeff, score, explained] = pca_and_plot(features_hml_log_less_ztrans(:,1:23),...
    1,2,TT_HML.Type,dark2([8 2 3 1],:),0,0);
title('sh, stream,[50 23]');
%axis([-20 10 -10 8])

subplot(3,2,2)
[h,coeff, score, explained] = pca_and_plot(features_hml_log_less_ztrans(:,24:46),...
    1,2,TT_HML.Type,dark2([8 2 3 1],:),0,0);
title('sh, cross,[50 23]');
%axis([-20 10 -10 8])

subplot(3,2,3)
[h,coeff, score, explained] = pca_and_plot(features_hml_log_less_ztrans(:,47:69),...
    1,2,TT_HML.Type,dark2([8 2 3 1],:),0,0);
title('sm, stream,[50 23]');
%axis([-20 10 -10 8])

subplot(3,2,4)
[h,coeff, score, explained] = pca_and_plot(features_hml_log_less_ztrans(:,70:92),...
    1,2,TT_HML.Type,dark2([8 2 3 1],:),0,0);
title('sm, cross,[50 23]');
%axis([-20 10 -10 8])

subplot(3,2,5)
[h,coeff, score, explained] = pca_and_plot(features_hml_log_less_ztrans(:,93:115),...
    1,2,TT_HML.Type,dark2([8 2 3 1],:),0,0);
title('sl, stream,[50 23]');
%axis([-20 10 -10 8])

subplot(3,2,6)
[h,coeff, score, explained] = pca_and_plot(features_hml_log_less_ztrans(:,116:end),...
    1,2,TT_HML.Type,dark2([8 2 3 1],:),0,0);
title('sl, cross,[50 23]');
%axis([-20 10 -10 8])

%% This is the working 'arrow' plot
% 1:23 24:46 47:69 70:92 93:115 116:138
[h,coeff, score, explained] = pca_arrow_plot3(features_hml_log_less_ztrans(:,1:46),...
     features_hml_log_less_ztrans(:,47:92),features_hml_log_less_ztrans(:,93:end)...
     ,1,2,TT_HML.Type,1,dark2([8 2 3 1],:),1,0);
%axis([-20 10 -10 8])
title('sh --> sm --> sl, stream, [50 23]')



%% sl --> sm --> sh
subplot(2,2,1)
[h,coeff, score, explained] = pca_arrow_plot3(features_hml_log_less_ztrans(:,93:115),...
     features_hml_log_less_ztrans(:,47:69),features_hml_log_less_ztrans(:,1:23)...
     ,1,2,TT_HML.Type,1,dark2([8 2 3 1],:),0,0);
%axis([-20 10 -10 8])
title('sl --> sm --> sh, stream, [50 23]')

subplot(2,2,2)
[h,coeff, score, explained] = pca_arrow_plot3(features_hml_log_less_ztrans(:,116:end),...
     features_hml_log_less_ztrans(:,70:92),features_hml_log_less_ztrans(:,24:46)...
     ,1,2,TT_HML.Type,1,dark2([8 2 3 1],:),0,0);
%axis([-20 10 -10 8])
title('sl --> sm --> sh, cross, [50 23]')


%% It would be nice to add some meaning!
subplot(2,2,3)
pca_and_plot(features_hml_log_less_ztrans(:,93:115),...
    1,2,TT_HML.Type,dark2([8 2 3 1],:),0,1)
title('vectors for above'); box on
%axis([-20 10 -10 8])

subplot(2,2,4)
pca_and_plot(features_hml_log_less_ztrans(:,116:end),...
    1,2,TT_HML.Type,dark2([8 2 3 1],:),0,1)
title('vectors for above'); box on
%axis([-20 10 -10 8])

