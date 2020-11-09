% This script plots the feature timeseries

%% 
% combine all features with high res wind and plot all together.
import_dt_info
path='C:\Users\tobyd\Documents\MATLAB\TreeMotion_Analysis\Save_features\FeatureData\';
load(strcat(path,'AB_STO_features_1hr.mat')) %% np
load(strcat(path,'AB_ORA_features_1hr.mat')) %
load(strcat(path,'AB_TOR_features_1hr.mat')) %
load(strcat(path,'Wytham_features_1hr.mat')) %% np
load(strcat(path,'TJ_Danum_features_1hr.mat')) %
load(strcat(path,'TvE_features_1hr.mat')) %
load(strcat(path,'ED_features_1hr.mat')) %% np
load(strcat(path,'RS_features_1hr.mat')) %
load(strcat(path,'AW_c_features_1hr.mat')) %% np
load(strcat(path,'AW_k_features_1hr.mat')) %%
load(strcat(path,'MD_features_1hr.mat'))  %% np
load(strcat(path,'DS_day_features_1hr.mat'))
load(strcat(path,'SvB_features_1hr.mat'))
load(strcat(path,'DC_features_1hr.mat'))
ABS=AB_STO_features_1hr;
ABT=AB_TOR_features_1hr;
ABO=AB_ORA_features_1hr;
TJW=Wytham_features_1hr;
TJD=TJ_Danum_features_1hr;
TvE=TvE_features_1hr;
MD=MD_features_1hr;
AWc=AW_c_features_1hr;
AWk=AW_k_features_1hr;
SvB=SvB_features_1hr;
DS=DS_day_features_1hr;
ED=ED_features_1hr;
RS=RS_features_1hr;
DC=DC_features_1hr;
clearvars AB_STO_features_1hr AB_ORA_features_1hr AB_TOR_features_1hr Wytham_features_1hr
clearvars TJ_Danum_features_1hr TvE_features_1hr MD_features_1hr AW_c_features_1hr DC_features_1hr
clearvars AW_k_features_1hr DS_day_features_1hr ED_features_1hr RS_features_1hr SvB_features_1hr
load(strcat(path,'names.mat'))

%% Split into summer / winter
% ED, DC!
% May 1st is good. Oct 1?
tree=1;
AWc_s=AWc(AWc(:,1,tree)<datenum(2005,10,1),:,:);
AWc_w=AWc(AWc(:,1,tree)>datenum(2005,10,1),:,:);

AWk_s=AWk(AWk(:,1,tree)<datenum(2006,10,1),:,:);
AWk_w=AWk(AWk(:,1,tree)>datenum(2006,10,1),:,:);

ABS_s=ABS(ABS(:,1,tree+1)>datenum(2013,05,1),:,:);
ABS_w=ABS(ABS(:,1,tree+1)<datenum(2013,05,1),:,:);

ABT_s=ABT(ABT(:,1,tree)<datenum(2014,10,1),:,:);
ABT_w=ABT(ABT(:,1,tree)>datenum(2014,10,1),:,:);

ABO_s=ABO(ABO(:,1,tree)>datenum(2015,05,1),:,:);
ABO_w=ABO(ABO(:,1,tree)<datenum(2015,05,1),:,:);

TJW_s=TJW(TJW(:,1,tree+18)>datenum(2016,05,1),:,:);
TJW_w=TJW(TJW(:,1,tree+18)<datenum(2016,05,1),:,:);

MD_s=MD(MD(:,1,2)<datenum(2018,10,1),:,:);
MD_w=MD(MD(:,1,2)>datenum(2018,10,1),:,:);

ED_s=ED(ED(:,1,2)>datenum(2017,05,1),:,:);
ED_w=ED(ED(:,1,2)<datenum(2017,05,1),:,:);

DC_s=cat(1,DC(DC(:,1,2)<datenum(2017,10,1),:,:),DC(find(DC(:,1,2)>datenum(2018,05,1) & DC(:,1,2)<datenum(2018,10,1)),:,:));
DC_w=cat(1,DC(DC(:,1,2)>datenum(2018,10,1),:,:),DC(find(DC(:,1,2)>datenum(2017,10,1) & DC(:,1,2)<datenum(2018,05,1)),:,:));

%%
plot(datetime(MD_s(:,1,2),'convertfrom','datenum'),MD_s(:,2,2))
hold on
plot(datetime(MD_w(:,1,2),'convertfrom','datenum'),MD_w(:,2,2))

%% Combine into one 4D array - I lose high res wind data
dt=nan(4000,     82,    129,   2);
%      time, feature,   tree, S/W
%ED,DS,DC, MD, TJW, TJD, TvE, OST, KC
dt(1:size(ED_s,1),1:82,1,1)=ED_s(:,:,2);
dt(1:size(ED_w,1),1:82,1,2)=ED_w(:,:,2);
dt(1:size(DS,1),1:82,2:5,1)=DS(:,:,2:5);
dt(1:size(DC_s,1),1:82,6:13,1)=DC_s(:,:,1:8);
dt(1:size(DC_w,1),1:82,6:13,2)=DC_w(:,:,1:8);

dt(1:size(MD_s,1),1:82,14:28,1)=MD_s(:,:,2:16);
dt(1:size(MD_w,1),1:82,14:28,2)=MD_w(:,:,2:16);
dt(1:size(TJW_s,1),1:82,29:49,1)=TJW_s(:,:,1:21);
dt(1:size(TJW_w,1),1:82,29:49,2)=TJW_w(:,:,1:21);
dt(1:size(TJD,1),1:82,50:54,1)=TJD(:,:,1:5);
dt(1:size(TvE,1),1:82,55:73,1)=TvE(:,:,1:19);
%OST, KC
dt(1:size(ABO_s,1),1:82,74:86,1)=ABO_s(:,:,1:13);
dt(1:size(ABO_w,1),1:82,74:86,2)=ABO_w(:,:,1:13);
dt(1:size(ABS_s,1),1:82,87:99,1)=ABS_s(:,:,1:13);
dt(1:size(ABS_w,1),1:82,87:99,2)=ABS_w(:,:,1:13);
dt(1:size(ABT_s,1),1:82,100:112,1)=ABT_s(:,:,1:13);
dt(1:size(ABT_w,1),1:82,100:112,2)=ABT_w(:,:,1:13);
dt(1:size(AWk_s,1),1:82,113:121,1)=AWk_s(:,:,2:10);
dt(1:size(AWk_w,1),1:82,113:121,2)=AWk_w(:,:,2:10);
dt(1:size(AWc_s,1),1:82,122:129,1)=AWc_s(:,:,2:9);
dt(1:size(AWc_w,1),1:82,122:129,2)=AWc_w(:,:,2:9);

%% Set up colours
Type5_ind=grp2idx(dt_info.Type5);
Site_ind=grp2idx(dt_info.Site);
dark2=brewermap(12,'dark2');
accent=brewermap(8,'accent');
ylorrd=brewermap(9,'YlOrRd');

%% Power law fitting
% 6 is max, 8 is 99th
% 10 is GEV k
% 12, 14 GEV sigma and mu might be more stable than max and 99th
% 18 is the Slope of Welch power spectra (0.05-2 Hz)
% 22 is ellipticalness
% 23 is f0_fq, then width, height, D0
% 52 is the Mean error from 1s forecast
%import_dt_info
fcol=8;
summary_dt=nan(129,10);
wind_mean_ratio=nan(129,15);
Type5_ind=grp2idx(dt_info.Type5);
%mmm=nan(129,6)
for tree=[2:5 30:129]
    if tree==29; continue; end
    if tree==13; continue; end
    if tree==124; continue; end
    tree
    dt_info.Filename(tree)
    xds=dt(:,2,tree,1); yds=100*dt(:,:,tree,1);
    keep_rows=find(isnan(xds)==0 & xds>0); yds=yds(keep_rows,:); xds=xds(keep_rows);
    
    if length(keep_rows)<10; continue; end
    [fit_power_S, gof] = fit_power_bisquare(xds, yds(:,fcol),'off');
    [fit_square_S]=fitlm(xds.^2,yds(:,fcol),'y~x1-1','robust','bisquare');
    summary_dt(tree,1:3)=cat(2,fit_power_S.a,fit_power_S.b,fit_square_S.Coefficients.Estimate(1));
    
    %wind_bins_summer=ceil(min(xds)):floor(max(xds));
    wind_bins=1:7;
    mmm=nan(length(wind_bins),8);
    for i=1:length(wind_bins)%ceil(min(xds)):floor(max(xds))-1
        temp_rows=find(xds>=i & xds<i+1);
        if length(temp_rows)<=2; continue; end
        mmm(i,1:4)=[mean(yds(temp_rows,fcol)),median(yds(temp_rows,fcol)),max(yds(temp_rows,fcol)),length(yds(temp_rows,fcol))];
    end

    %summary_dt(tree,4:5)=cat(2,mean(yds(:,23),'omitnan'),median(yds(:,23),'omitnan'));
    
    xdw=dt(:,2,tree,2); ydw=100*dt(:,:,tree,2);
    keep_rows=find(isnan(xdw)==0 & xdw>0); ydw=ydw(keep_rows,:); xdw=xdw(keep_rows);
    if size(ydw,1)<10; continue; end
    [fit_power_W, gof] = fit_power_bisquare(xdw, ydw(:,fcol),'off');
    [fit_square_W]=fitlm(xdw.^2,ydw(:,fcol),'y~x1-1','robust','bisquare');
    summary_dt(tree,4:6)=cat(2,fit_power_W.a,fit_power_W.b,fit_square_W.Coefficients.Estimate(1));
    
    %wind_bins_winter=ceil(min(xds)):floor(max(xds));
    for i=1:length(wind_bins)%ceil(min(xds)):floor(max(xds))-1
        temp_rows=find(xdw>=i & xdw<i+1);
        if length(temp_rows)<=2; continue; end
        mmm(i,5:8)=[mean(ydw(temp_rows,fcol)),median(ydw(temp_rows,fcol)),max(ydw(temp_rows,fcol)),length(ydw(temp_rows,fcol))];
    end
    wind_mean_ratio(tree,1:length(wind_bins))=mmm(:,1)./mmm(:,5);
    wind_median_ratio(tree,1:length(wind_bins))=mmm(:,2)./mmm(:,6);
    wind_max_ratio(tree,1:length(wind_bins))=mmm(:,3)./mmm(:,7);
    wind_summer_n(tree,1:length(wind_bins))=mmm(:,4);
    wind_winter_n(tree,1:length(wind_bins))=mmm(:,8);
    %subplot(2,2,2)
    %[xint, yint] = fit_spline_tsfeatures(wind_bins,wind_mean_ratio(tree,:),1,0.7);
    %plot(xint, yint,'color',cat(2,accent(Type5_ind(tree)+2,:),0.4),'linewidth',1); 
    %hold on; ylim([0 5]); xlim([1 10]); box on; ylabel('Summer / winter')
    %plot(wind_bins,wind_ratio(tree,:),'color',cat(2,dark2(col_ind(tree),:),0.6)); hold on
    %pause
    if tree==78
        subplot(2,2,1)  
        h1=scatter(xds,yds(:,fcol),3.2,dark2(1,:),'filled','MarkerFaceAlpha',1); hold on
        h=plot(fit_power_S); legend off; set(h,'color',dark2(1,:),'linewidth',1.2); hold on
        h2=scatter(xdw,ydw(:,fcol),3.2,dark2(8,:),'filled','MarkerFaceAlpha',1); hold on
        h=plot(fit_power_W); legend off; set(h,'color',dark2(8,:),'linewidth',1.2);
        
        ylabel('Max inclination angle °');  xlabel('Wind speed (m/s)');
        lgd=legend([h1, h2],{'Summer','Winter'},'location','southeast'); 
        legend boxoff; 
        box on;
        
    end
    if 1==2
        subplot(1,2,2)  
        h1=scatter(xds.^2,yds(:,fcol),3.2,dark2(1,:),'filled','MarkerFaceAlpha',1); hold on
        h=plot(fit_square_S); legend off; set(h,'color',dark2(1,:),'linewidth',1.2); hold on
        h2=scatter(xdw.^2,ydw(:,fcol),3.2,dark2(8,:),'filled','MarkerFaceAlpha',1); hold on
        h=plot(fit_square_W); legend off; set(h,'color',dark2(8,:),'linewidth',1.2);
        
        ylabel('Inclination angle'); xlabel ''; %xlabel('Wind speed'); 
        lgd=legend([h1, h2],{'Summer','Winter'},'location','northwest'); 
        legend boxoff; 
        box on;
        xlabel('Wind speed (m/s)');
        %pause; close all
    end
    summary_dt(tree,9:10)=cat(2,mean(ydw(:,23),'omitnan'),median(ydw(:,23),'omitnan'));
    %pause
end
set(gca,'fontsize', 10)
%subplot(2,2,2)
%
%legend('Angio','Gymno'); legend boxoff; 

%%
boxplot(wind_mean_ratio(2:end,4),dt_info.Type2(2:end)); %ylim([-1 4])

%%

subplot(1,2,1)
hist(wg)
subplot(1,2,2)
hist(wa)

%%
ws=2;
wg=wind_mean_ratio(find(dt_info.Type2=='Gymno'),ws); wg(isnan(wg)==1)=[]; 
wa=wind_mean_ratio(find(dt_info.Type2=='Angio'),ws); wa(isnan(wa)==1)=[]; 
a=nan(length(wa),2);
a(:,1)=wa; a(1:length(wg),2)=wg;

violin(a,'xlabel',{strcat('Broadleaf ',' N=',num2str(length(wa))), strcat('Conifer ',' N=',num2str(length(wg)))},...
   'facecolor',dark2(1:2,:),'medc',''); legend off; 

%% VIOLIN PLOT SQUARE COEFF
subplot(2,2,2)
dt_info_filt=dt_info(isnan(summary_dt(:,6))==0,:);
summary_dt_filt=summary_dt(isnan(summary_dt(:,6))==0,:);
coeff=summary_dt_filt(:,3)./summary_dt_filt(:,6);
coeff_gymno=find(dt_info_filt.Type5=='Gymno.Forest');
coeff_angio=find(dt_info_filt.Type5=='Angio.Forest');
a=nan(length(coeff_angio),2);
a(:,1)=coeff(coeff_angio); 
a(1:length(coeff_gymno),2)=coeff(coeff_gymno);
[h, p]=ttest2(coeff_gymno,coeff_angio)
violin(a,'xlabel',{strcat('Broadleaf ',' N=',num2str(length(coeff_angio))), strcat('Conifer ',' N=',num2str(length(coeff_gymno)))},...
   'facecolor',accent([3 5],:),'medc',''); legend off; 
ylim([0 4]); yticks([0 1 2 3 4])
ylabel('Summer / winter coefficient')
set(gca,'FontSize',10)
%%
mat2clip(summary_dt)

%% Slope of the spectrum - summer and winter
subplot(2,2,3)
fcol=18;
ds=1; sp=0.9; lw=3;
for tree=78%:129
    tree
    dt_info.Filename(tree)
    xd=dt(:,2,tree,1); yd=dt(:,fcol,tree,1);
    xd=xd(isnan(yd)==0); yd=yd(isnan(yd)==0);
    yd=yd(isnan(xd)==0); xd=xd(isnan(xd)==0);
    yd=yd(xd>0); xd=xd(xd>0);
    if length(yd)<10; continue; end
    scatter(xd,yd,3.2,dark2(1,:),'filled','MarkerFaceAlpha',1); hold on
    [xint, yint] = fit_spline_tsfeatures(xd,yd,ds,sp);
    h1=plot( xint,yint,'color',cat(2,dark2(1,:),0.6),'LineWidth',lw);  hold on
    ylim([-4 0.1])
    %pause
    
    xd=dt(:,2,tree,2); yd=dt(:,fcol,tree,2);
    xd=xd(isnan(yd)==0); yd=yd(isnan(yd)==0);
    yd=yd(isnan(xd)==0); xd=xd(isnan(xd)==0);
    yd=yd(xd>0); xd=xd(xd>0);
    if length(yd)<10; continue; end
    scatter(xd,yd,3.2,dark2(8,:),'filled','MarkerFaceAlpha',1); hold on
    [xint, yint] = fit_spline_tsfeatures(xd,yd,ds,sp);
    h2=plot( xint,yint,'color',cat(2,dark2(8,:),0.3),'LineWidth',lw);  hold on
    xlabel('Wind speed (m/s)'); ylabel('Power spectrum slope');
    ylim([-4 0.1]); 
    box on;
    %lgd=legend([h1, h2],{'Summer','Winter'},'location','northeast'); 
    %pause; close all;    
end
% 78
set(gca,'fontsize', 10)

 %% Smoothing splines - all trees, SW combined

ds=1; sp=0.9; lw=1;
fcol=18;
%fcol=22; % Ellipticalness

for tree=[6 15 2:5 15:54 74:129]
    tree
    if tree==66; continue; end
    if tree==69; continue; end
    dt_info.Filename(tree)
    xds=dt(:,2,tree,1); yds=dt(:,:,tree,1);
    xdw=dt(:,2,tree,2); ydw=dt(:,:,tree,2);
    xd=cat(1,xdw,xds); yd=cat(1,ydw,yds);
    keep_rows=find(isnan(xd)==0 & xd>0.1); yd=yd(keep_rows,:); xd=xd(keep_rows);
    if length(keep_rows)<10; continue; end
    subplot(2,2,4)
    fcol=18; 
    [xint, yint] = fit_spline_tsfeatures(xd,yd(:,fcol),1,0.9);
    h1=plot( xint,yint,'color',cat(2,accent(Type5_ind(tree)+2,:),0.4),'LineWidth',1);  hold on  
    xlabel('Wind speed (m/s)');  ylabel('Power spectrum slope');
    xlim([0 10]); ylim([-4 0]); box on; 
    %pause; %close all;     
end
set(gca,'fontsize', 10)
%subplot(1,3,1)
%legend('Angio','Gymno'); legend boxoff; 

 %% Smoothing splines - all trees, SW combined

ds=1; sp=0.9; lw=1;
fcol=18;
%fcol=22; % Ellipticalness

for tree=[6 15 2:5 15:54 74:129]
    tree
    if tree==66; continue; end
    if tree==69; continue; end
    dt_info.Filename(tree)
    xds=dt(:,2,tree,1); yds=dt(:,:,tree,1);
    xdw=dt(:,2,tree,2); ydw=dt(:,:,tree,2);
    xd=cat(1,xdw,xds); yd=cat(1,ydw,yds);
    keep_rows=find(isnan(xd)==0 & xd>1); yd=yd(keep_rows,:); xd=xd(keep_rows);
    if size(yd,1)<10; continue; end
    subplot(1,3,1)
    fcol=18; 
    [xint, yint] = fit_spline_tsfeatures(xd,yd(:,fcol),1,0.9);
    h1=plot( xint,yint,'color',cat(2,accent(Type5_ind(tree)+2,:),0.4),'LineWidth',1);  hold on  
    xlabel('Wind speed (m/s)');  ylabel('Welch spectrum slope');
    title('0.05 - 2 Hz')
    xlim([1 10]); ylim([-5 1]); box on; 
    subplot(1,3,2)
    fcol=16; 
    [xint, yint] = fit_spline_tsfeatures(xd,yd(:,fcol),1,0.9);
    h1=plot( xint,yint,'color',cat(2,accent(Type5_ind(tree)+2,:),0.4),'LineWidth',1);  hold on  
    xlabel('Wind speed (m/s)') 
    title('0.05 - 0.8 Hz')
    xlim([1 10]); ylim([-5 1]); box on; 
    subplot(1,3,3)
    fcol=20; 
    [xint, yint] = fit_spline_tsfeatures(xd,yd(:,fcol),1,0.9);
    h1=plot( xint,yint,'color',cat(2,accent(Type5_ind(tree)+2,:),0.4),'LineWidth',1);  hold on  
    xlabel('Wind speed (m/s)')  
    title('1 - 2 Hz')
    xlim([1 10]); ylim([-5 1]); box on; 
    %pause; %close all;     
end
set(gca,'fontsize', 10)
%subplot(1,3,1)
%legend('Angio','Gymno'); legend boxoff; 
%%
    
%6: 
 %% Smoothing splines
% 6 is max, 8 is 99th
% 10 is GEV k
% 12, 14 GEV sigma and mu might be more stable than max and 99th
% 18 is the Slope of Welch power spectra (0.05-2 Hz)
% 22 is ellipticalness
% 23 is f0_fq, then width, height, D0
% 52 is the Mean error from 1s forecast
%import_dt_info
% 16, 18, 20, 28,29,30,
%subplot(2,2,4)
Type5_ind=grp2idx(dt_info.Type5);
ds=1; sp=0.9; lw=1;
fcol=29;

summary_dt=nan(129,10);
for tree=1:129
    tree
    dt_info.Filename(tree)
    xds=dt(:,2,tree,1); yds=dt(:,:,tree,1);
    keep_rows=find(isnan(xds)==0 & xds>0); yds=yds(keep_rows,:); xds=xds(keep_rows);
    if size(yds,1)<10; continue; end
    [xint, yint] = fit_spline_tsfeatures(xds,yds(:,fcol),ds,sp);
    subplot(1,2,1)
    h1=plot( xint,yint,'color',cat(2,dark2(Type5_ind(tree),:),0.3),'LineWidth',lw);  hold on  

    xdw=dt(:,2,tree,2); ydw=dt(:,:,tree,2);
    keep_rows=find(isnan(xdw)==0 & xdw>0); ydw=ydw(keep_rows,:); xdw=xdw(keep_rows);
    if size(ydw,1)<10; continue; end
    [xint, yint] = fit_spline_tsfeatures(xdw,ydw(:,fcol),ds,sp);
    subplot(1,2,2)
    h2=plot( xint,yint,'color',cat(2,dark2(Type5_ind(tree),:),0.3),'LineWidth',lw);  hold on
        
    %pause; close all;     
end
%%
names{fcol-4}
subplot(1,2,1)
title('Summer')
xlabel('Wind speed (m/s)'); 
ylabel('Welch spectrum slope stream 0.05-2 Hz');

ylim([-5 1])
subplot(1,2,2)
title('Winter')
xlabel('Wind speed (m/s)'); %ylabel('Welch spectrum slope');
ylim([-5 1])



%%
%% Boxplot - tree mean summer winter ratio
boxplot(wind_mean_ratio(2:end,2),dt_info.Type2(2:end)); %ylim([-1 4])

%% BOXPLOTS - Exponents in summer and winter - consistent
subplot(2,4,1)
boxplot(summary_dt(2:end,2),dt_info.Type2(2:end)); ylim([-1 4])
title('Exponent Summer'); ylabel('All data')
subplot(2,4,2)
boxplot(summary_dt(2:end,5),dt_info.Type2(2:end)); ylim([-1 4])
title('Exponent Winter')

% Change in coefficient summer --> winter - consistent
subplot(2,4,3)
boxplot(summary_dt(2:end,1)./summary_dt(2:end,4),dt_info.Type2(2:end)); ylim([0 5])
title('Coeff change power')
subplot(2,4,4)
boxplot(summary_dt(2:end,3)./summary_dt(2:end,6),dt_info.Type2(2:end)); ylim([0 5])
title('Coeff change square')
% This is all similar whichever metric for max we use

% Filter good rows
keep_rows=find(summary_dt(:,2)>=1 & summary_dt(:,5)>=1);
dt_info_filt=dt_info(keep_rows,:);
summary_dt_filt=summary_dt(keep_rows,:);

subplot(2,4,5)
boxplot(summary_dt_filt(2:end,2),dt_info_filt.Type2(2:end)); ylim([-1 4])
title('Exponent Summer'); ylabel('Exponents >=1')
exps=[min(summary_dt_filt(2:end,2)), median(summary_dt_filt(2:end,2)), max(summary_dt_filt(2:end,2))]
subplot(2,4,6)
boxplot(summary_dt_filt(2:end,5),dt_info_filt.Type2(2:end)); ylim([-1 4])
exps=[min(summary_dt_filt(2:end,5)), median(summary_dt_filt(2:end,5)), max(summary_dt_filt(2:end,5))]
title('Exponent Winter')

% Change in coefficient summer --> winter - consistent
subplot(2,4,7)
boxplot(summary_dt_filt(2:end,1)./summary_dt_filt(2:end,4),dt_info_filt.Type2(2:end)); ylim([0 6])
ylabel('Coefficient summer / winter')
title('Coeff change power')
subplot(2,4,8)
boxplot(summary_dt_filt(2:end,3)./summary_dt_filt(2:end,6),dt_info_filt.Type2(2:end)); ylim([0 5])
title('Coeff change square')
% This is all similar whichever metric for max we use

%%
hist(summary_dt(:,2))