function [a, b, c] = slope_of_spectrum2(data_in,fs,PLOT)
% This function takes some data, calculates the welch power spectrum and
% then finds the slope of that spectrum between given limits.
        data_in(isnan(data_in)==1)=[];
       [pxx,f] = pwelch(data_in,[],[],[],fs); 
       robust='off';
       % Slope 1
       f1=0.05; f2=2;
       xfit=f(f>=f1 & f<=f2);
       yfit=pxx(f>=f1 & f<=f2);
       fit1=fitlm(log(xfit),log(yfit),'robustopts',robust);
       a=fit1.Coefficients.Estimate(2);
       
       % Slope 2
       f1=0.3; f2=2;
       xfit=f(f>=f1 & f<=f2);
       yfit=pxx(f>=f1 & f<=f2);
       fit2=fitlm(log(xfit),log(yfit),'robustopts',robust);
       b=fit2.Coefficients.Estimate(2);
       
       % Slope 3
       f1=1; f2=2;
       xfit=f(f>=f1 & f<=f2);
       yfit=pxx(f>=f1 & f<=f2);
       fit3=fitlm(log(xfit),log(yfit),'robustopts',robust);
       c=fit3.Coefficients.Estimate(2);
       
       if PLOT==2
            %subplot(1,2,1); plot(data_in)
            %subplot(1,2,2);     
            plot(log(f),log(pxx),'.')
            hold on;  plot(fit2); legend off     
            %xt=log([0.001 0.01 0.1 0.5 2 5 10]);    xticks((xt));  xlim([(0.001) (10)]);
            %xticklabels({num2str(xt(1)) ,num2str(xt(2)), num2str(xt(3)), num2str(xt(4)) ,num2str(xt(5)) ,num2str(xt(6)),num2str(xt(7))});
            xticks(log([0.05 0.2 0.35  0.5  1]));  xticklabels({'0.05','0.2', '0.35', '0.5','1'}) 
            ax = gca; ax.XGrid = 'on';
            textLoc(strcat('Exponent = ',num2str(round(fit1.Coefficients.Estimate(2),3))),'NorthEast');
            pause; close all;
       end
        
       if PLOT==1
            %subplot(1,2,1); plot(data_in)
            %subplot(1,2,2);     
            plot(log(f(f>=0.02 & f<=2)),log(pxx(f>=0.02 & f<=2)),'.')
            hold on;  plot(fit1); legend off     
            xt=[0.001 0.01 0.1 0.5 2 5 10];    xticks(log(xt)); 
            xticklabels({num2str(xt(1)) ,num2str(xt(2)), num2str(xt(3)), num2str(xt(4)) ,num2str(xt(5)) ,num2str(xt(6)),num2str(xt(7))});
            grid on;
            %xticks(log([0.05 0.2 0.35  0.5  1]));  xticklabels({'0.05','0.2', '0.35', '0.5','1'}) 
            textLoc(strcat(num2str(round(fit1.Coefficients.Estimate(2),3))),'NorthEast');
            hold off
       end
end

