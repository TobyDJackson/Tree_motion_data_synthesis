function [fit_result] = plot_welch(tree_in,fs_tree,wind_in,fs_wind,...
            Ebba,wind_label,color_in,LineStyle,p_smooth,PLOT)
    
    if istable(tree_in); tree_in=table2array(tree_in); end
    if istable(wind_in); wind_in=table2array(wind_in); end
    
    colx=size(tree_in,2)-1;
    coly=size(tree_in,2);
    
    % Prepare the data
    tree_corrected = replace_nan_with_col_mean(tree_in);
    tree_corrected=tree_corrected-mean(tree_corrected,'omitnan'); %subtract the mean?
    tree_corrected=cat(2,tree_corrected,hypot(tree_corrected(:,colx),tree_corrected(:,coly)));%add the resultant
    
    % Calcuate Welch Power spectra
	[pxx_tree,f_tree] = pwelch(tree_corrected,[],[],[],fs_tree); % Calculate the welch power transform for all columns
    pxx_tree(f_tree>=fs_tree/2,:)=[]; f_tree(f_tree>=fs_tree/2)=[]; %delete the mirror half
    
    if fs_wind>0 % If there is wind data
        wind_corrected = replace_nan_with_col_mean(wind_in);
        [pxx_wind,f_wind] = pwelch(wind_corrected,[],[],[],fs_wind); % Calculate the welch power transform for all columns
        pxx_wind(f_wind>=fs_wind/2,:)=[]; f_wind(f_wind>=fs_wind/2)=[]; %delete the mirror half
    end
    
    if Ebba==1 % pre-multiply by f as suggested by Ebba
        pxx_tree=cat(2,f_tree.*pxx_tree(:,1),f_tree.*pxx_tree(:,2),f_tree.*pxx_tree(:,3));
        if fs_wind>0
            pxx_wind=cat(2,f_wind.*pxx_wind);
        end
    end
    
    % Calculate transfer functions
    if fs_wind==fs_tree 
        pxx_tf_x=pxx_tree(:,colx)./pxx_tree(:,1); % Energy transfer from the wind to the tree
        pxx_tf_y=pxx_tree(:,coly)./pxx_tree(:,1);
        pxx_tf_abs=pxx_tree(:,coly+1)./pxx_tree(:,1); % combined column 
    end
        
    %% Plotting
    
    % Transfer function of combined tree motion
    if PLOT==1 
        xlim([log(0.001) log(fs_tree/2)]);
        [fit_result, gof] = fit_spline_pxx(log(f_tree),log(pxx_tf_abs),1,p_smooth);
        h1=plot( fit_result ); legend off;
        set(h1,'color',color_in,'LineWidth',1.2,'LineStyle',LineStyle)   
        xlim([log(0.001) log(10)]);
    end
    
    % Transfer function of separate tree motion channels
    if PLOT==2
        xlim([log(0.001) log(fs_tree/2)]);
        [fit_result_x, gof] = fit_spline_pxx(log(f_tree),log(pxx_tf_x),1,p_smooth);
        h1=plot( fit_result_x ); legend off; hold on;
        set(h1,'color',color_in,'LineWidth',1,'LineStyle','-')
        [fit_result_y, gof] = fit_spline_pxx(log(f_tree),log(pxx_tf_y),1,p_smooth);
        h2=plot( fit_result_y ); legend off;
        set(h2,'color',color_in,'LineWidth',1.2,'LineStyle',':')
        xlim([log(0.001) log(10)]);
    end
    
    % Power spectrum of combined tree motion + wind (if available)
    if PLOT==3
        if fs_wind>0;
            xlim([log(0.001) log(fs_wind/2)]);
            [fit_result_wind, gof] = fit_spline_pxx(log(f_wind),log(pxx_wind(:,1)),1,p_smooth);
            h1=plot( fit_result_wind ); legend off; hold on;
            set(h1,'color','black','LineWidth',1.5,'LineStyle','-')  
        end
        
        xlim([log(0.001) log(fs_tree/2)]);
        [fit_result_abs, gof] = fit_spline_pxx(log(f_tree),log(pxx_tree(:,coly+1)),1,p_smooth);
        h2=plot( fit_result_abs ); legend off; hold on;
        set(h2,'color',color_in,'LineWidth',1.2,'LineStyle',LineStyle) 
        xlim([log(0.001) log(10)]);
    end
    
    % Power spectrum of separate tree motion + wind (if available)
    if PLOT==4
        if fs_wind>0
            xlim([log(0.001) log(fs_wind/2)]);
            [fit_result_wind, gof] = fit_spline_pxx(log(f_wind),log(pxx_wind(:,1)),1,p_smooth);
            h1=plot( fit_result_wind ); legend off; hold on;
            set(h1,'color',color_in,'LineWidth',1.5,'LineStyle','-')
        end
        xlim([log(0.001) log(fs_tree/2)]);
        [fit_result_abs, gof] = fit_spline_pxx(log(f_tree),log(pxx_tree(:,colx)),1,p_smooth);
        h2=plot( fit_result_abs ); legend off; hold on;
        set(h2,'color',color_in,'LineWidth',1.2,'LineStyle',LineStyle)
        [fit_result_abs, gof] = fit_spline_pxx(log(f_tree),log(pxx_tree(:,coly)),1,p_smooth);
        h2=plot( fit_result_abs ); legend off; hold on;
        set(h2,'color',color_in,'LineWidth',1.2,'LineStyle',LineStyle)
    
        xlim([log(0.001) log(10)]);
    end
    
    % POINTS NOT LINES Power spectrum of separate tree motion + wind (if available)
    if PLOT==5
        if fs_wind>0
            xlim([log(0.001) log(fs_wind/2)]);
            %[fit_result_wind, gof] = fit_spline_pxx(,1,p_smooth);
            h1=plot( log(f_wind),log(pxx_wind(:,1)) ); legend off; hold on;
            set(h1,'color','black')
        end
        xlim([log(0.001) log(fs_tree/2)]);
        %[fit_result_abs, gof] = fit_spline_pxx(log(f_tree),log(pxx_tree(:,colx)),1,p_smooth);
        h2=plot( log(f_tree),log(pxx_tree(:,colx)) ); legend off; hold on;
        set(h2,'color',color_in)
        %[fit_result_abs, gof] = fit_spline_pxx(log(f_tree),log(pxx_tree(:,coly)),1,p_smooth);
        h2=plot( log(f_tree),log(pxx_tree(:,coly)) ); legend off; hold on;
        set(h2,'color',color_in)
    
        xlim([log(0.001) log(10)]);
    end
 
    xt=[0.001 0.01 0.1 0.5 2 5 10];    xticks(log(xt));  
    xticklabels({num2str(xt(1)) ,num2str(xt(2)), num2str(xt(3)), num2str(xt(4)) ,num2str(xt(5)) ,num2str(xt(6)),num2str(xt(7))}); 
    %grid off; 
    ax = gca; ax.XGrid = 'on';
    xlabel ''; ylabel '';
    %yticklabels '';
    
    if wind_label==1;
        textLoc(strcat('WS=',num2str(round(mean(wind_in(:,1),'omitnan'),2))));
    end
    %ylabel('Power (dB)'); 
    xlabel('Frequency (Hz)');    
    %xlabel '';
end

