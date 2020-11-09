function [EH,VH,AH,RH] = SSA_plot_HML(ZH,ZM,ZL,EBD,sf,sample)

    ZH_filt = replace_nan_with_col_mean(ZH-mean(ZH,'omitnan'));   
    ZM_filt = replace_nan_with_col_mean(ZM-mean(ZM,'omitnan'));   
    ZL_filt = replace_nan_with_col_mean(ZL-mean(ZL,'omitnan'));   
    
    %sf  = 4;                  % Sampling frequency (Hz)
    Nyf = 0.5 * sf;           % Nyquist-frequency (Hz    
    hp=0.0017; % this is ten minutes
    fOrder        = 4;  
    [b2,a2]       = butter(fOrder,hp / Nyf,'high');

    ZH_hp = filtfilt(b2,a2,ZH_filt);
    ZM_hp = filtfilt(b2,a2,ZM_filt);
    ZL_hp = filtfilt(b2,a2,ZL_filt);
    %figure; hold on; yyaxis left; plot(ZH_filt); yyaxis right; plot(ZH_hp,'r'); legend('ZH_filt','Strain bandpass')

    if 1==2;
        [EH,VH,AH,RH] = ssa(ZH_filt',EBD);
        [EM,VM,AM,RM] = ssa(ZM_filt',EBD);
        [EL,VL,AL,RL] = ssa(ZL_filt',EBD);
    end
    
    if 1==1;
        [EH,VH,AH,RH] = ssa(ZH_hp',EBD);
        [EM,VM,AM,RM] = ssa(ZM_hp',EBD);
        [EL,VL,AL,RL] = ssa(ZL_hp',EBD);
    end
    dark2=brewermap(8,'dark2');
    
    if 1==2
        % Scree plot
        subplot(3,1,1)
        plot(VH,'-g+');  ylabel('Explained variance'); xlabel('Embedding dimension'); hold on
        mean_arr = repmat(mean(VH),1:length(mean(VH)),1);
        plot(1:length(VH),mean_arr,'-k+'); title('TJ high')
         axis([0 10 0 1]); hold on

        subplot(3,1,2)
        plot(VM,'-g+');  hold on
        mean_arr = repmat(mean(VM),1:length(mean(VM)),1);
        plot(1:length(VM),mean_arr,'-k+'); title(strcat('med (ebd=',num2str(EBD),')'))
        axis([0 10 0 1])

        subplot(3,1,3)
        plot(VL,'-g+');  hold on
        mean_arr = repmat(mean(VL),1:length(mean(VL)),1);
        plot(1:length(VL),mean_arr,'-k+'); title low
         axis([0 10 0 1])
         xlabel('Component #') 
    end
    
    %figure
     if 1==1
        % Scree plot
        subplot(2,3,1)
        plot(VH,'-g+');  hold on; title High;
        mean_arr = repmat(mean(VH),1:length(mean(VH)),1);
        plot(1:length(VH),mean_arr,'-k+'); 
        axis([0 10 0 1]); hold on
        ylabel('Variance explained');  xlabel('Component #') 
        axis([0 10 0 1]); hold on; %title('TJ - Wytham')

        subplot(2,3,2)
        plot(VM,'-g+');  hold on; title Medium
        mean_arr = repmat(mean(VM),1:length(mean(VM)),1);
        plot(1:length(VM),mean_arr,'-k+'); %title(strcat('embedding dimension =',num2str(EBD)))
        ylabel ''; yticklabels ''; xlabel('Component #') 
        axis([0 10 0 1]); hold on; 

        subplot(2,3,3)
        plot(VL,'-g+');  hold on; title Low
        mean_arr = repmat(mean(VL),1:length(mean(VL)),1);
        plot(1:length(VL),mean_arr,'-k+'); 
        ylabel ''; yticklabels '';  xlabel('Component #') 
        axis([0 10 0 1]); 
        %[kaic,kmdl,aic,mdl]=itc(VH,length(Z));
        %plot(1:length(VH),aic,'-k+');


        % Time series plot
        subplot(2,3,4)
        plot(RH(sample,1),'color',dark2(1,:)); hold on;     plot(RH(sample,2),'color',dark2(2,:)); 
        plot(RH(sample,3),'color',dark2(3,:));   plot(RH(sample,4),'color',dark2(4,:));
        xlabel('time');
        

        subplot(2,3,5)
        plot(RM(sample,1),'color',dark2(1,:)); hold on;     plot(RM(sample,2),'color',dark2(2,:)); 
        plot(RM(sample,3),'color',dark2(3,:));   plot(RM(sample,4),'color',dark2(4,:));
        ylabel ''; yticklabels ''; xlabel('time');

        subplot(2,3,6)
        plot(RL(sample,1),'color',dark2(1,:)); hold on;     plot(RL(sample,2),'color',dark2(2,:)); 
        plot(RL(sample,3),'color',dark2(3,:));   plot(RL(sample,4),'color',dark2(4,:));
        ylabel ''; yticklabels ''; xlabel('time');
        legend('Component 1','Component 2','Component 3','Component 4')
     end 
    
end

