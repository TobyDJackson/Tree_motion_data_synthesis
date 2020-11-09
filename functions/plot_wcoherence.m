function [total_coherence,frequency] = plot_wcoherence(data_in,fs,color_in,LineStyle,PLOT)
    
    % wind,treex,treey,t
    t=replace_nan_with_col_mean(data_in(:,1));
    wind=replace_nan_with_col_mean(data_in(:,2));
    treex=replace_nan_with_col_mean(data_in(:,3));
    treey=replace_nan_with_col_mean(data_in(:,4));

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
    if 1==1 % subtract mean
            wind=wind-mean(wind,'omitnan');
            treex = treex-mean(treex,'omitnan');
            treey = treey-mean(treey,'omitnan');
    end
      
    tree_abs=hypot(treex,treey);
    
    %% Plotting below here
    if PLOT==1 
        [wcoh,~,period] = wcoherence(wind,tree_abs,seconds(1/fs));
        period = seconds(period);
        total_coherence=mean(wcoh,2);
        frequency=log(1./period);
    
        plot(frequency,total_coherence,'color',color_in,'LineWidth',1,'LineStyle',LineStyle);
    end

    if PLOT==2
        [wcohx,~,period] = wcoherence(wind,treex,seconds(1/fs));
        total_coherencex=mean(wcohx,2);
        [wcohy,~,period] = wcoherence(wind,treey,seconds(1/fs));
        total_coherencey=mean(wcohy,2);

        period = seconds(period);
        frequency=log(1./period);
        
        plot(frequency,total_coherencex,'color',color_in,'LineWidth',1,'LineStyle',LineStyle); hold on;
        plot(frequency,total_coherencey,'color',color_in,'LineWidth',1,'LineStyle',LineStyle);
    end
    
    grid off
    xt=[0.001 0.01 0.1 0.5 2 5 10];    xticks(log(xt));    xlim([log(0.001) log(10)]);
    
    ax = gca; ax.XGrid = 'on'; ax.YGrid = 'off';
    xticklabels({num2str(xt(1)) ,num2str(xt(2)), num2str(xt(3)), num2str(xt(4)) ,num2str(xt(5)) ,num2str(xt(6)),num2str(xt(7))}); grid on;
    
    
    %% Ignore below - don't use this in a loop
     if PLOT==3 % FULL COHERENCE + SUMMARY 
        subplot(1,3,[1 2])
        h = pcolor(t,log2(1./period),wcoh);
        colormap autumn
        colorbar
        h.EdgeColor = 'none';
        ax = gca;
        yt=[0.001 0.01 0.1 0.5 2 5 10];    yticks(log(yt));    ylim([log(0.001) log(10)]);
        yticklabels({num2str(yt(1)) ,num2str(yt(2)), num2str(yt(3)), num2str(yt(4)) ,num2str(yt(5)) ,num2str(yt(6)),num2str(yt(7))}); grid on;
        ylabel('Frequency (Hz)')
        
        xt=[0 0.5 1];    xticks(xt);    %ylim([log(0.001) log(10)]);
        xticklabels({num2str(yt(1)) ,num2str(yt(2)), num2str(yt(3))}); grid on;
        title('ED low')
        
        subplot(1,3,3)     
        h = plot(total_coherence,frequency);
        yt=[0.001 0.01 0.1 0.5 2 5 10];    yticks(log(yt));    ylim([log(0.001) log(10)]);
        set(h,'color','black','LineWidth',1.2,'LineStyle','-')
        yticklabels({num2str(yt(1)) ,num2str(yt(2)), num2str(yt(3)), num2str(yt(4)) ,num2str(yt(5)) ,num2str(yt(6)),num2str(yt(7))}); grid on;
        xlabel ''
        

    end
end

