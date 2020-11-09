function [EH,VH,AH,RH] = SSA_plot_HML2(ZH,ZM,ZL,EBD,sf,sample,col)
    

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
        [EH,VH,AH,RH] = ssa(sqrt(ZH_filt1.^2+ZH_filt2.^2)',EBD);
        [EM,VM,AM,RM] = ssa(sqrt(ZM_filt1.^2+ZM_filt2.^2)',EBD);
        [EL,VL,AL,RL] = ssa(sqrt(ZL_filt1.^2+ZL_filt2.^2)',EBD);
    end
    
    if 1==1;
        [EH,VH,AH,RH] = ssa(sqrt(ZH_hp1.^2+ZH_hp2.^2)',EBD);
        [EM,VM,AM,RM] = ssa(sqrt(ZM_hp1.^2+ZM_hp2.^2)',EBD);
        [EL,VL,AL,RL] = ssa(sqrt(ZL_hp1.^2+ZL_hp2.^2)',EBD);
    end
    
    dark2=brewermap(8,'dark2');
    
    if 1==1
        % Scree plot
        subplot(3,1,1)
        plot(VH,'color',col);  ylabel('var - high');  hold on
        plot(VH,'color',col,'marker','+'); 
        xticklabels '';
        axis([0 10 0 1]); hold on; title('TJ')

        subplot(3,1,2)
        plot(VM,'color',col);  hold on; ylabel('var - med');
        plot(VM,'color',col,'marker','+');
        title(strcat('embedding dimension =',num2str(EBD)))
        axis([0 10 0 1])

        subplot(3,1,3)
        plot(VL,'color',col);  hold on; ylabel('var - low');
        plot(VL,'color',col,'marker','+');
        xlabel('Embedding dimension');
        axis([0 10 0 1])
    end
    
    if 1==2
        % Scree plot
        subplot(3,2,1)
        plot(VH,'-g+');  ylabel('Explained variance'); xlabel('Embedding dimension'); hold on
        axis([0 10 0 1]);   title('MD')

        subplot(3,2,3)
        plot(VM,'-g+');  hold on
        axis([0 10 0 1]);  title(strcat('med (ebd=',num2str(EBD),')'))

        subplot(3,2,5)
        plot(VL,'-g+');  hold on
        axis([0 10 0 1])
        %[kaic,kmdl,aic,mdl]=itc(VH,length(Z));
        %plot(1:length(VH),aic,'-k+');


        % Time series plot
        subplot(3,2,2)
        plot(RH(sample,1),'color',dark2(1,:)); hold on;     plot(RH(sample,2),'color',dark2(2,:)); 
        plot(RH(sample,3),'color',dark2(3,:));   plot(RH(sample,4),'color',dark2(4,:));
        legend('R1','R2','R3','R4')

        subplot(3,2,4)
        plot(RM(sample,1),'color',dark2(1,:)); hold on;     plot(RM(sample,2),'color',dark2(2,:)); 
        plot(RM(sample,3),'color',dark2(3,:));   plot(RM(sample,4),'color',dark2(4,:));

        subplot(3,2,6)
        plot(RL(sample,1),'color',dark2(1,:)); hold on;     plot(RL(sample,2),'color',dark2(2,:)); 
        plot(RL(sample,3),'color',dark2(3,:));   plot(RL(sample,4),'color',dark2(4,:));
     end 
    
    
end

