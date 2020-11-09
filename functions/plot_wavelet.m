function [wfreq_tree,tf_abs] = plot_wavelet(tree_in,fs_tree,wind_in,fs_wind,...
                Ebba,wind_label,color_in,LineStyle,PLOT)
            
    if istable(tree_in); tree_in=table2array(tree_in); end
    if istable(wind_in); wind_in=table2array(wind_in); end
    
    colx=size(tree_in,2)-1;
    coly=size(tree_in,2);
    
    % Prepare the data
    tree_corrected = replace_nan_with_col_mean(tree_in);
    tree_corrected=tree_corrected-mean(tree_corrected,'omitnan'); %subtract the mean?
    tree_abs=hypot(tree_corrected(:,colx),tree_corrected(:,coly));%add the resultant
        
    % Calculate combined spectra
    if isEven(PLOT)==0 
        [coeffs_tree,wfreq_tree] = cwt(tree_abs, 'amor',fs_tree);  % This matlab function does all the work
        glowspec_tree = sum(abs(coeffs_tree).^2,2);                      % Wavelet power spectrum measured data
        spectrum_tree=glowspec_tree./(max(glowspec_tree)-min(glowspec_tree));
    end
    
    % Calculate separate x and y spectra
    if isEven(PLOT)==1 
        [coeffs_treex,wfreq_tree] = cwt(tree_corrected(:,colx), 'amor',fs_tree);  % This matlab function does all the work
        glowspec_treex = sum(abs(coeffs_treex).^2,2);                      % Wavelet power spectrum measured data
        spectrum_treex=glowspec_treex./(max(glowspec_treex)-min(glowspec_treex));
        
        [coeffs_treey,wfreq_tree] = cwt(tree_corrected(:,coly), 'amor',fs_tree);  % This matlab function does all the work
        glowspec_treey = sum(abs(coeffs_treey).^2,2);                      % Wavelet power spectrum measured data
        spectrum_treey=glowspec_treey./(max(glowspec_treey)-min(glowspec_treey));
    end
    
    if fs_wind>0 % If there is wind data
        wind_corrected = replace_nan_with_col_mean(wind_in);
        [coeffs_wind,wfreq_wind] = cwt(wind_corrected(:,1), 'amor',fs_wind);  % This matlab function does all the work
        glowspec_wind = sum(abs(coeffs_wind).^2,2);                      % Wavelet power spectrum measured data
        spectrum_wind=glowspec_wind./(max(glowspec_wind)-min(glowspec_wind));
    end
         

    %% PLOTTING BELOW HERE
 
    %dark2=brewermap(8,'dark2');
    % Plot the combined transfer function
    if PLOT==1
        tf_abs=spectrum_tree./spectrum_wind;
        semilogx(wfreq_tree,tf_abs,'color',color_in,'LineWidth',0.8,'LineStyle',LineStyle);  grid off;
    end
    
    % Plot the separate x and y transfer functions
    if PLOT==2
        tfx=spectrum_treex./spectrum_wind;
        tfy=spectrum_treey./spectrum_wind;
        semilogx(wfreq_tree,tfx,'color',color_in,'LineWidth',0.8,'LineStyle',LineStyle); hold on 
        semilogx(wfreq_tree,tfy,'color',color_in,'LineWidth',1.2,'LineStyle',':'); 
    end
    
    % Plot the tree abs spectrum and wind spectrum
    if PLOT==3
        if fs_wind>0
            semilogx(wfreq_wind,spectrum_wind,'color','black','LineWidth',1.5,'LineStyle','-');  hold on
        end
        semilogx(wfreq_tree,spectrum_tree,'color',color_in,'LineWidth',1.2,'LineStyle',LineStyle); hold on
    end
    
    if PLOT==4
        if fs_wind>0
            semilogx(wfreq_wind,spectrum_wind,'color','black','LineWidth',1.5,'LineStyle','-');  hold on
        end
        semilogx(wfreq_tree,spectrum_treex,'color',color_in,'LineWidth',1.2,'LineStyle',LineStyle); hold on
        semilogx(wfreq_tree,spectrum_treey,'color',color_in,'LineWidth',1.2,'LineStyle',LineStyle); hold on
    end
    
    
    if wind_label==1
        textLoc(strcat('WS=',num2str(round(mean(wind_in(:,1),'omitnan'),1)))); 
    end
    xlabel('Frequency Hz');   legend off;  grid off; 
    xt=[0.001 0.01 0.1 0.5 2 5 10];    xticks((xt));  xlim([(0.001) (10)]);
    xticklabels({num2str(xt(1)) ,num2str(xt(2)), num2str(xt(3)), num2str(xt(4)) ,num2str(xt(5)) ,num2str(xt(6)),num2str(xt(7))});
    ax = gca; ax.XGrid = 'on';
    
end

