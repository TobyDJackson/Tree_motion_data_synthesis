
function [fit_result_abs_diff] = plot_welch_diff(tree_in_high,tree_in_low,fs_tree,...
            wind_in_high,wind_in_low,fs_wind,Ebba,color_in,LineStyle,p_smooth,PLOT)
    
    if istable(tree_in_high); tree_in_high=table2array(tree_in_high); end
    if istable(tree_in_low);  tree_in_low= table2array(tree_in_low); end
    if istable(wind_in_high); wind_in_high=table2array(wind_in_high); end
    if istable(wind_in_low);  wind_in_low= table2array(wind_in_low); end
    
    colx=size(tree_in_high,2)-1;
    coly=size(tree_in_high,2);
    
    % Prepare the data
    data_temp_high = replace_nan_with_col_mean(tree_in_high);
    data_temp_high = data_temp_high-mean(data_temp_high,'omitnan');
    data_temp_high=cat(2,data_temp_high,hypot(data_temp_high(:,colx),data_temp_high(:,coly)));
    
    data_temp_low = replace_nan_with_col_mean(tree_in_low);
    data_temp_low = data_temp_low-mean(data_temp_low,'omitnan');
    data_temp_low=cat(2,data_temp_low,hypot(data_temp_low(:,colx),data_temp_low(:,coly)));
    
	[pxx_tree_high,f_tree] = pwelch(data_temp_high,[],[],[],fs_tree); 
    [pxx_tree_low,f_tree] = pwelch(data_temp_low,[],[],[],fs_tree); 

    
    if fs_wind>0 % If there is wind data
        wind_corrected_high = replace_nan_with_col_mean(wind_in_high);
        [pxx_wind_high,f_wind] = pwelch(wind_corrected_high,[],[],[],fs_wind); % Calculate the welch power transform for all columns
        pxx_wind_high(f_wind>=fs_wind/2,:)=[]; f_wind(f_wind>=fs_wind/2)=[]; %delete the mirror half
        wind_corrected_low = replace_nan_with_col_mean(wind_in_low);
        [pxx_wind_low,f_wind] = pwelch(wind_corrected_low,[],[],[],fs_wind); % Calculate the welch power transform for all columns
        pxx_wind_low(f_wind>=fs_wind/2,:)=[]; f_wind(f_wind>=fs_wind/2)=[]; %delete the mirror half
    end

    if 1==2
        % Energy transfer from the wind to the tree
        pxx_tf_abs_high=pxx_tree_high(:,coly+1)./pxx_wind_high(:,1); 
        pxx_tf_abs_low=pxx_tree_low(:,coly+1)./pxx_wind_low(:,1); 
    end
    
    if Ebba==1 % pre-multiply by f as suggested by Ebba
        pxx_tree_high=cat(2,f_tree.*pxx_tree_high(:,1),f_tree.*pxx_tree_high(:,2),f_tree.*pxx_tree_high(:,3));
        pxx_tree_low=cat(2,f_tree.*pxx_tree_low(:,1),f_tree.*pxx_tree_low(:,2),f_tree.*pxx_tree_low(:,3));
        if fs_wind>0
            pxx_wind_high=cat(2,f_wind.*pxx_wind_high);
            pxx_wind_low=cat(2,f_wind.*pxx_wind_low);
        end
    end
    %% Plotting
    
    % Change in transfer function of combined tree motion
    if PLOT==1
        xlim([log(0.001) log(fs_tree/2)]);
        [fit_result_abs_diff, gof] = fit_spline_pxx(log(f_tree),log(pxx_tf_abs_high)-log(pxx_tf_abs_low),1,p_smooth);
        h1=plot( fit_result_abs_diff ); legend off;
        set(h1,'color',color_in,'LineWidth',1.2,'LineStyle',LineStyle)   
        xlim([log(0.001) log(10)]);
    end
    
    % NOT DONE THIS YET.
    if PLOT==2
        xlim([log(0.001) log(fs_tree/2)]);
        [fit_result_abs_high, gof] = fit_spline_pxx(log(f_tree),log(pxx_tf_abs_high),1,p_smooth);
        h1=plot( fit_result_abs_high ); legend off;
        set(h1,'color',color_in,'LineWidth',1.2,'LineStyle',LineStyle)   
        xlim([log(0.001) log(10)]); 
    end
    
    % Change in power spectrum of combined tree motion + wind (if available)
    if PLOT==3
        if fs_wind>0
            xlim([log(0.001) log(fs_wind/2)]);
            [fit_result_wind_diff, gof] = fit_spline_pxx(log(f_wind),log(pxx_wind_high(:,1))-log(pxx_wind_low(:,1)),1,p_smooth);
            h1=plot( fit_result_wind_diff ); legend off; hold on;
            set(h1,'color','black','LineWidth',1.5,'LineStyle','-')
        end
        xlim([log(0.001) log(fs_tree/2)]);
        [fit_result_abs_diff, gof] = fit_spline_pxx(log(f_tree),log(pxx_tree_high(:,coly+1))-log(pxx_tree_low(:,coly+1)),1,p_smooth);
        h2=plot( fit_result_abs_diff ); legend off; hold on;
        set(h2,'color',color_in,'LineWidth',1.2,'LineStyle',LineStyle)
        xlim([log(0.001) log(10)]);
    end
    
    if PLOT==4
        if fs_wind>0
            xlim([log(0.001) log(fs_wind/2)]);
            [fit_result_wind_diff, gof] = fit_spline_pxx(log(f_wind),log(pxx_wind_high(:,1))-log(pxx_wind_low(:,1)),1,p_smooth);
            h1=plot( fit_result_wind_diff ); legend off; hold on;
            set(h1,'color','black','LineWidth',1.5,'LineStyle','-')
        end
        xlim([log(0.001) log(fs_tree/2)]);
        [fit_result_abs_diff, gof] = fit_spline_pxx(log(f_tree),log(pxx_tree_high(:,colx))-log(pxx_tree_low(:,colx)),1,p_smooth);
        h2=plot( fit_result_abs_diff ); legend off; hold on;
        set(h2,'color',color_in,'LineWidth',1.2,'LineStyle',LineStyle)
        [fit_result_abs_diff, gof] = fit_spline_pxx(log(f_tree),log(pxx_tree_high(:,coly))-log(pxx_tree_low(:,coly)),1,p_smooth);
        h2=plot( fit_result_abs_diff ); legend off; hold on;
        set(h2,'color',color_in,'LineWidth',1.2,'LineStyle',LineStyle)
        xlim([log(0.001) log(10)]);
    end
    
    hold on;
    plot([log(0.001) log(10)], [0 0],'color','black','LineWidth',1,'LineStyle','--')
    xt=[0.001 0.01 0.1 0.5 2 5 10];    xticks(log(xt));    
    xticklabels({num2str(xt(1)) ,num2str(xt(2)), num2str(xt(3)), num2str(xt(4)) ,num2str(xt(5)) ,num2str(xt(6)),num2str(xt(7))}); 
    %grid off; 
    ax = gca; ax.XGrid = 'on';
    xlabel ''; ylabel '';
    %yticklabels '';
    
    %ylabel('Power (dB)'); 
    xlabel('Frequency (Hz)');    
    %xlabel '';
end

