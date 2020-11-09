function [exponent, fit1, pxx, f] = slope_of_spectrum(data_in,fs,f1,f2,robust,PLOT)
% This function takes some data, calculates the welch power spectrum and
% then finds the slope of that spectrum between given limits.
       %data_in(isnan(data_in)==1)=[];
       [pxx,f] = pwelch(data_in,[],[],[],fs); 
       xfit=f(f>=f1 & f<=f2,:);
       yfit=pxx(f>=f1 & f<=f2,:);
       fit1=fitlm(log(xfit),log(yfit),'robustopts',robust);
       exponent=fit1.Coefficients.Estimate(2);
       
       PLOT=0
       if PLOT==1
            subplot(1,2,1); plot(data_in)
            subplot(1,2,2);     plot(log(f(f>=0.02 & f<=2)),log(pxx(f>=0.02 & f<=2)),'.')
            hold on;  plot(fit1); legend off     
            xticks(log([0.05 0.2 0.35  0.5  1]));  xticklabels({'0.05','0.2', '0.35', '0.5','1'}) 
            textLoc(strcat('Exponent = ',num2str(round(fit1.Coefficients.Estimate(2),3))),'NorthEast');
        end
end

