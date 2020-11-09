function [wfreq,y] = global_wavelet_plot(in,SF,color_in,LineStyle,offset,PLOT)

    % This matlab function does all the work
    in_temp = in-mean(in,'omitnan');
    in_temp = replace_nan_with_col_mean(in_temp);
    [coeffs1,wfreq,coi1] = cwt(in_temp, 'amor',SF,'NumOctaves',8,'VoicesPerOctaves',16);  % I need to test the sensitivity to these two parameters 
    wspec1    = abs(coeffs1).^2;                      % Wavelet power spectrum measured data
    glowspec1 = sum(wspec1,2);                        % Global wavelet spectrum measured data
    y=5.*glowspec1./(max(glowspec1)-min(glowspec1));
    color1=brewermap(8,'dark2');
    if PLOT==1
        semilogx(wfreq,y+offset,'color',color_in,'LineWidth',1.2,'LineStyle',LineStyle);  grid off;
        xlabel('Hz');ylabel('GWV'); 
        legend off;      
        xt=[0.01 0.1 0.5 2 5 10];    xticks((xt));  xlim([(0.0001) (10)]);
        xticklabels({num2str(xt(1)) ,num2str(xt(2)), num2str(xt(3)), num2str(xt(4)) ,num2str(xt(5)) ,num2str(xt(6))});
         grid on;
    end
end

