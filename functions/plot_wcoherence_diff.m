function [total_coherence,frequency] = ...
    plot_wcoherence_diff(data_in_high,data_in_low,fs,color_in,LineStyle,PLOT)
    
    % wind,treex,treey,t
    data_high = replace_nan_with_col_mean(data_in_high);
    data_low = replace_nan_with_col_mean(data_in_low);
    if 1==2 % HighPass filter       
            Nyf = 0.5 * fs; % Nyquist-frequency (Hz)    
            lower_frequency_threshold=0.0017; % this is ten minutes
            fOrder        = 4;  
            [b2,a2]       = butter(fOrder,lower_frequency_threshold / Nyf,'high');
            treex = filtfilt(b2,a2,treex);
            treey = filtfilt(b2,a2,treey);
            %subplot(2,1,1); plot(data(:,1))
            %subplot(2,1,2); plot(data_test(:,1))  
    end
    if 1==1 % subtract offsets?
        data_low(:,2:4)=data_low(:,2:4)-mean(data_low(:,2:4),'omitnan')
        data_high(:,2:4)=data_high(:,2:4)-mean(data_high(:,2:4),'omitnan');
    end
    t=data_high(:,1);
    wind_high=data_high(:,2);
    tree_abs_high=hypot(data_high(:,3),data_high(:,4));
    
    wind_low=data_low(:,2);
    tree_abs_low=sqrt(data_low(:,3).^2+data_low(:,4).^2);
     
    if PLOT==1
        [wcoh_high,~,period] = wcoherence(wind_high,tree_abs_high,seconds(1/fs));
        total_coherence_high=mean(wcoh_high,2);
        [wcoh_low,~,period] = wcoherence(wind_low,tree_abs_low,seconds(1/fs));
        total_coherence_low=mean(wcoh_low,2);
        period = seconds(period);
        frequency=log(1./period);  
        plot(frequency,total_coherence_high-total_coherence_low,'color',color_in,'LineWidth',1,'LineStyle',LineStyle); hold on
    end
    
    if PLOT==2
        [wcoh_highx,~,period] = wcoherence(wind_high,data_high(:,3),seconds(1/fs));
        total_coherence_highx=mean(wcoh_highx,2);
        [wcoh_highy,~,period] = wcoherence(wind_high,data_high(:,4),seconds(1/fs));
        total_coherence_highy=mean(wcoh_highy,2);
        
        [wcoh_lowx,~,period] = wcoherence(wind_low,data_low(:,3),seconds(1/fs));
        total_coherence_lowx=mean(wcoh_lowx,2);
        [wcoh_lowy,~,period] = wcoherence(wind_low,data_low(:,4),seconds(1/fs));
        total_coherence_lowy=mean(wcoh_lowy,2);
        
        period = seconds(period);
        frequency=log(1./period);  
        %plot([log(0.001) log(10)], [0 0],'color','black','LineWidth',1,'LineStyle','--'); hold on;
        plot(frequency,total_coherence_highx-total_coherence_lowx,'color',color_in,'LineWidth',1,'LineStyle',LineStyle); hold on;
        plot(frequency,total_coherence_highy-total_coherence_lowy,'color',color_in,'LineWidth',1,'LineStyle',LineStyle);

    end
    
    plot([log(0.001) log(10)], [0 0],'color','black','LineWidth',1,'LineStyle','--'); hold on;
    xt=[0.001 0.01 0.1 0.5 2 5 10]; xticks(log(xt)); xlim([log(0.001) log(10)]);grid off;
    xticklabels({num2str(xt(1)) ,num2str(xt(2)), num2str(xt(3)), num2str(xt(4)) ,num2str(xt(5)) ,num2str(xt(6)),num2str(xt(7))}); 
    ax = gca; ax.XGrid = 'on'; ax.YGrid='off';
    
end

