
function [h1, pxx_temp, f_temp, fitresult, x, y] = pwelch_plot(f_temp, pxx_temp,ds,sp, color_in,LineStyle,offset,PLOT)
    
    
    % Check length of pxx and fit a spline;
    len_fit=length(pxx_temp)./(ds*1000);
    if len_fit>=200; a=input(strcat('fit -',num2str(len_fit),'k samples?')); end
    [x, y] = prepareCurveData( downsample(log(f_temp),ds), downsample(log(pxx_temp),ds) );
    y(x<log(0.001))=[]; y(x>log(10))=[]; x(x<log(0.001))=[]; x(x>log(10))=[];
    y=y-y(end)+offset;
    ft = fittype( 'smoothingspline' ); opts = fitoptions( 'Method', 'SmoothingSpline' ); opts.Normalize = 'on';
    opts.SmoothingParam = sp; %lower is smoother
    [fitresult, gof] = fit( x, y, ft, opts );
    
    color1=brewermap(8,'dark2');
    if PLOT==1
        %plot(x,y,'.','color',color1(8,:)); hold on; 
        xlim([min(x) max(x)]); 
        h1=plot( fitresult ); ylabel('Power (dB)'); xlabel('Frequency (Hz)');    set(h1,'color',color_in,'LineWidth',1.2,'LineStyle',LineStyle)
        legend off;     xt=[0.001 0.01 0.1 0.5 2 5 10];    xticks(log(xt));    xlim([log(0.001) log(10)]);
        xticklabels({num2str(xt(1)) ,num2str(xt(2)), num2str(xt(3)), num2str(xt(4)) ,num2str(xt(5)) ,num2str(xt(6)),num2str(xt(7))}); grid on;
    end
    
    if PLOT==2
        subplot(1,2,1);     
        plot(in,'color',color1(8,:));     textLoc(len_in,'NorthWest');    %hold on

        subplot(1,2,2)
        plot(x,y,'.','color',color1(8,:)); hold on;     xlim([min(x) max(x)]);
        h1=plot( fitresult ); ylabel('dB'); xlabel('Hz');    set(h1,'color',color_in,'LineWidth',1.2)
      legend off;     xt=[0.001 0.01 0.1 0.5 2 5 10];    xticks(log(xt));    xlim([log(0.001) log(10)]);
        xticklabels({num2str(xt(1)) ,num2str(xt(2)), num2str(xt(3)), num2str(xt(4)) ,num2str(xt(5)) ,num2str(xt(6)),num2str(xt(7))}); grid on;
    end


end

