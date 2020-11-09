function [EH1,VH1,AH1,RH1] = SSA_plot_HML3(ZH,ZM,ZL,EBD,sf,sample,col)
    

    Nyf = 0.5 * sf;           % Nyquist-frequency (Hz)    
    lower_frequency_threshold=0.0017; % this is ten minutes
    fOrder        = 4;  
    [b2,a2]       = butter(fOrder,lower_frequency_threshold / Nyf,'high');
    
    ZH1=ZH(:,1); ZH2=ZH(:,2);
    ZM1=ZM(:,1); ZM2=ZM(:,2);
    ZL1=ZL(:,1); ZL2=ZL(:,2);
    
    ZH_filt1 = replace_nan_with_col_mean(ZH1-mean(ZH1,'omitnan'));   
    ZM_filt1 = replace_nan_with_col_mean(ZM1-mean(ZM1,'omitnan'));   
    ZL_filt1 = replace_nan_with_col_mean(ZL1-mean(ZL1,'omitnan'));
    
    ZH_filt2 = replace_nan_with_col_mean(ZH2-mean(ZH2,'omitnan'));   
    ZM_filt2 = replace_nan_with_col_mean(ZM2-mean(ZM2,'omitnan'));   
    ZL_filt2 = replace_nan_with_col_mean(ZL2-mean(ZL2,'omitnan'));  
    
    ZH_hp1 = filtfilt(b2,a2,ZH_filt1);
    ZM_hp1 = filtfilt(b2,a2,ZM_filt1);
    ZL_hp1 = filtfilt(b2,a2,ZL_filt1);
    
    ZH_hp2 = filtfilt(b2,a2,ZH_filt2);
    ZM_hp2 = filtfilt(b2,a2,ZM_filt2);
    ZL_hp2 = filtfilt(b2,a2,ZL_filt2);


    if 1==2;
        [EH1,VH1,AH1,RH1] = ssa(ZH_filt1',EBD);
        [EM1,VM1,AM1,RM1] = ssa(ZM_filt1',EBD);
        [EL1,VL1,AL1,RL1] = ssa(ZL_filt1',EBD);
        [EH2,VH2,AH2,RH2] = ssa(ZH_filt2',EBD);
        [EM2,VM2,AM2,RM2] = ssa(ZM_filt2',EBD);
        [EL2,VL2,AL2,RL2] = ssa(ZL_filt2',EBD);
    end
    
    if 1==1;
        [EH1,VH1,AH1,RH1] = ssa(ZH_hp1',EBD);
        [EM1,VM1,AM1,RM1] = ssa(ZM_hp1',EBD);
        [EL1,VL1,AL1,RL1] = ssa(ZL_hp1',EBD);
        [EH2,VH2,AH2,RH2] = ssa(ZH_hp2',EBD);
        [EM2,VM2,AM2,RM2] = ssa(ZM_hp2',EBD);
        [EL2,VL2,AL2,RL2] = ssa(ZL_hp2',EBD);
    end
    
    dark2=brewermap(8,'dark2');
    
    if 1==1
        % Scree plot
        subplot(1,3,1)
        plot(VH1,'color',col,'LineStyle','-','marker','+');  hold on;   
        plot(VH2,'color',col,'LineStyle',':','marker','+');  hold on; 
        ylabel('Hartheim'); %xticklabels ''; 
        axis([0 8 0 1]); hold on; %title('ED & SK')

        subplot(1,3,2)
        plot(VM1,'color',col,'LineStyle','-','marker','+');  hold on;   
        plot(VM2,'color',col,'LineStyle',':','marker','+');  hold on; 
        %ylabel('var - med'); %xticklabels ''; 
        %title(strcat('embedding dimension =',num2str(EBD)))
        axis([0 8 0 1])

        subplot(1,3,3)
        plot(VL1,'color',col,'LineStyle','-','marker','+');  hold on;   
        plot(VL2,'color',col,'LineStyle',':','marker','+');  hold on; 
        %ylabel('var - low');
        %xlabel('Component #') 
        axis([0 8 0 1])
    end
    
   
    
    
end

