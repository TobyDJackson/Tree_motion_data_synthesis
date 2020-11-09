function [pxx, f, fitresult, x, y,h1] = power_spectrum_plot(in,SamplingFrequency,DownSample,SmoothingP, color_in,LineStyle,offset,PLOT)
    
    % Prepare variables and check length
    in(isnan(in)==1)=[];
    len_in=strcat( num2str(round(length(in)./(SamplingFrequency*60*60),1)),' hours');
    disp(len_in)
    
    % Calculate power spectrum
    [pxx,f] = pwelch(in,[],[],[],SamplingFrequency); 
    
    % Check length of pxx and fit a spline;
    len_fit=length(in)./(DownSample*1000);
    if len_fit>=200; a=input(strcat('fit -',num2str(len_fit),'k samples?')); end
    [x, y] = prepareCurveData( downsample(log(f),DownSample), downsample(log(pxx),DownSample) );
    y(x<log(0.01))=[]; y(x>log(10))=[]; x(x<log(0.01))=[]; x(x>log(10))=[];
    y=y-y(end)+offset;
    ft = fittype( 'smoothingspline' ); opts = fitoptions( 'Method', 'SmoothingSpline' ); opts.Normalize = 'on';
    opts.SmoothingParam = SmoothingP; %lower is smoother
    [fitresult, gof] = fit( x, y, ft, opts );
    
    color1=brewermap(8,'dark2');
    if PLOT==1
        %plot(x,y,'.','color',color1(8,:)); hold on; 
        xlim([min(x) max(x)]); 
        h1=plot( fitresult ); ylabel('Power (dB)'); xlabel('Frequency (Hz)');    set(h1,'color',color_in,'LineWidth',1.2,'LineStyle',LineStyle)
        legend off;     xt=[0.01 0.1 0.5 2 5 10];    xticks(log(xt));    xlim([log(0.01) log(10)]);
        xticklabels({num2str(xt(1)) ,num2str(xt(2)), num2str(xt(3)), num2str(xt(4)) ,num2str(xt(5)) ,num2str(xt(6))}); grid on;
    end
    
    if PLOT==2
        subplot(1,2,1);     
        plot(in,'color',color1(8,:));     textLoc(len_in,'NorthWest');    %hold on

        subplot(1,2,2)
        plot(x,y,'.','color',color1(8,:)); hold on;     xlim([min(x) max(x)]);
        h1=plot( fitresult ); ylabel('dB'); xlabel('Hz');    set(h1,'color',color_in,'LineWidth',1.2)
        legend off;      xt=[0.01 0.1 0.5 2 5 10];    xticks(log(xt));  xlim([log(0.01) log(10)]); grid on;
        xticklabels({num2str(xt(1)) ,num2str(xt(2)), num2str(xt(3)), num2str(xt(4)) ,num2str(xt(5)) ,num2str(xt(6))});
    end


end

