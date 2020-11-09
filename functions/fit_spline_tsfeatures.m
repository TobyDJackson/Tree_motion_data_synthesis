function [xint, yint] = fit_spline_tsfeatures(x,y,ds,sp)

    % Fit a spline to pxx or transfer function
    
    %ds,sp
    % Check length of pxx and fit a spline;
    %len_fit=length(pxx_in)./(ds*1000);
    %if len_fit>=200; a=input(strcat('fit -',num2str(len_fit),'k samples?')); end
    
    [x, y] = prepareCurveData( downsample(x,ds), downsample(y,ds) );
    
    %y(x<log(0.001))=[]; 
    %y(x>log(10))=[]; 
    %x(x<log(0.001))=[]; 
    %x(x>log(10))=[];
    
    %y=y-y(end);
    
    ft = fittype( 'smoothingspline' ); 
    opts = fitoptions( 'Method', 'SmoothingSpline' ); 
    opts.Normalize = 'on';
    opts.SmoothingParam = sp; %lower is smoother
    
    [fit_result, gof] = fit( x, y, ft, opts );
    
    xint=linspace(min(x),max(x),100);
    yint=fit_result(xint);
    
    if 1==2
        subplot(1,3,1)
        plot(f_in,pxx_in,'.')
        subplot(1,3,2)
        plot(x,-y,'.')
        subplot(1,3,3)
        plot(fit_result)
    end
end

