function [wfreq_tree,tf_abs_high] = plot_wavelet_diff(tree_in_high,tree_in_low,fs_tree,...
                 wind_in_high,wind_in_low,fs_wind,Ebba,color_in,LineStyle,PLOT)
    
    if istable(tree_in_high); tree_in_high=table2array(tree_in_high); end
    if istable(tree_in_low);  tree_in_low =table2array(tree_in_low); end
    if istable(wind_in_high); wind_in_high=table2array(wind_in_high); end
    if istable(wind_in_low);  wind_in_low =table2array(wind_in_low); end
    
    colx=size(tree_in_high,2)-1;
    coly=size(tree_in_high,2);
    
    tree_corrected_high=replace_nan_with_col_mean(tree_in_high);
    tree_corrected_high=tree_corrected_high-mean(tree_corrected_high,'omitnan');
    tree_abs_high = hypot(tree_corrected_high(:,colx),tree_corrected_high(:,coly));
    
    tree_corrected_low=replace_nan_with_col_mean(tree_in_low);
    tree_corrected_low=tree_corrected_low-mean(tree_corrected_low,'omitnan');
    tree_abs_low = hypot(tree_corrected_low(:,colx),tree_corrected_low(:,coly));
     
    % Calculate combined spectra
    if isEven(PLOT)==0 
        % Calculate combined transfer function
        [coeffs_tree_high,wfreq_tree] = cwt(tree_abs_high, 'amor',fs_tree);  % This matlab function does all the work
        glowspec_tree_high = sum(abs(coeffs_tree_high).^2,2);                      % Wavelet power spectrum measured data
        spectrum_tree_high=glowspec_tree_high./(max(glowspec_tree_high)-min(glowspec_tree_high));

        [coeffs_tree_low,wfreq_tree] = cwt(tree_abs_low, 'amor',fs_tree);  % This matlab function does all the work
        glowspec_tree_low = sum(abs(coeffs_tree_low).^2,2);                      % Wavelet power spectrum measured data
        spectrum_tree_low=glowspec_tree_low./(max(glowspec_tree_low)-min(glowspec_tree_low));
    end
    
    % Calculate separate x and y spectra
    if isEven(PLOT)==1 
        [coeffs_treex_high,wfreq_tree] = cwt(tree_corrected_high(:,colx), 'amor',fs_tree); 
        glowspec_treex_high = sum(abs(coeffs_treex_high).^2,2);                      
        spectrum_treex_high = glowspec_treex_high./(max(glowspec_treex_high)-min(glowspec_treex_high));
        
        [coeffs_treey_high,wfreq_tree] = cwt(tree_corrected_high(:,coly), 'amor',fs_tree); 
        glowspec_treey_high = sum(abs(coeffs_treey_high).^2,2);                      
        spectrum_treey_high = glowspec_treey_high./(max(glowspec_treey_high)-min(glowspec_treey_high));
        
        [coeffs_treex_low,wfreq_tree] = cwt(tree_corrected_low(:,colx), 'amor',fs_tree); 
        glowspec_treex_low = sum(abs(coeffs_treex_low).^2,2);                     
        spectrum_treex_low = glowspec_treex_low./(max(glowspec_treex_low)-min(glowspec_treex_low));
        
        [coeffs_treey_low,wfreq_tree] = cwt(tree_corrected_low(:,coly), 'amor',fs_tree);  
        glowspec_treey_low = sum(abs(coeffs_treey_low).^2,2);                     
        spectrum_treey_low = glowspec_treey_low./(max(glowspec_treey_low)-min(glowspec_treey_low));
    end
    
    
    if fs_wind>0 % Calculate wind spectrum
        wind_corrected_high=replace_nan_with_col_mean(wind_in_high);
        wind_corrected_low =replace_nan_with_col_mean(wind_in_low);
        
        [coeffs_wind_high,wfreq_wind] = cwt(wind_corrected_high(:,1), 'amor',fs_wind); 
        glowspec_wind_high = sum(abs(coeffs_wind_high).^2,2);                   
        spectrum_wind_high=glowspec_wind_high./(max(glowspec_wind_high)-min(glowspec_wind_high));

        [coeffs_wind_low,wfreq_wind] = cwt(wind_corrected_low(:,1), 'amor',fs_wind);  
        glowspec_wind_low = sum(abs(coeffs_wind_low).^2,2);                      
        spectrum_wind_low=glowspec_wind_low./(max(glowspec_wind_low)-min(glowspec_wind_low));
     end

    %% PLOTTING BELOW HERE
    
    % Plot the combined transfer function
    if PLOT==1
        tf_abs_diff=tf_abs_high-tf_abs_low;
        semilogx(wfreq_tree,tf_abs_diff,'color',color_in,'LineWidth',0.8,'LineStyle',LineStyle);   
    end
    
    if PLOT==3
        semilogx(wfreq_tree,spectrum_tree_high-spectrum_tree_low,'color',color_in,'LineWidth',1.2,'LineStyle',LineStyle);  
        hold on
        if fs_wind>0
            semilogx(wfreq_wind,spectrum_wind_high-spectrum_wind_low,'color','black','LineWidth',1.5,'LineStyle','-');  
        end
    end
    
    if PLOT==4
        semilogx(wfreq_tree,spectrum_treex_high-spectrum_treex_low,'color',color_in,'LineWidth',1.2,'LineStyle',LineStyle);  
        hold on
        semilogx(wfreq_tree,spectrum_treey_high-spectrum_treey_low,'color',color_in,'LineWidth',1.2,'LineStyle',LineStyle);  
        if fs_wind>0
            semilogx(wfreq_wind,spectrum_wind_high-spectrum_wind_low,'color','black','LineWidth',1.5,'LineStyle','-');  
        end
    end
    
    hold on
    plot([0.001 10], [0 0],'color','black','LineWidth',1,'LineStyle','--'); grid off; 
    yl=ylim; outer=max(abs(yl)); ylim([-1*outer outer]);    %outer=1.1*outer;  %yticks([-1*outer 0 outer]);
    
    xt=[0.001 0.01 0.1 0.5 2 5 10];    xticks((xt));  xlim([(0.001) (10)]);
    xticklabels({num2str(xt(1)) ,num2str(xt(2)), num2str(xt(3)), num2str(xt(4)) ,num2str(xt(5)) ,num2str(xt(6)),num2str(xt(7))});
    ax = gca; ax.XGrid = 'on';
    xlabel('Frequency Hz'); legend off;    
    
end

