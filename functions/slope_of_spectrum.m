function [exponent, fit1, pxx, f] = slope_of_spectrum(data_in,fs,f1,f2,robust,PLOT)
% This function takes some data, calculates the welch power spectrum and
% then finds the slope of that spectrum between given limits.
       data_in(isnan(data_in)==1)=[];
       [pxx,f] = pwelch(data_in,[],[],[],fs); 
       xfit=f(f>=f1 & f<=f2);
       yfit=pxx(f>=f1 & f<=f2);
       fit1=fitlm(log(xfit),log(yfit),'robustopts',robust);
       exponent=fit1.Coefficients.Estimate(2);
       
       [z] = binned_log_means(f,pxx,100,0.001);
            fz=z(:,1); pxxz=z(:,2); 
            xfitz=fz(fz>=f1 & fz<=f2);
           yfitz=pxxz(fz>=f1 & fz<=f2);
           fit2=fitlm(log(xfitz),log(yfitz),'robustopts',robust);
           exponent2=fit2.Coefficients.Estimate(2);

       if PLOT==2  
            plot(log(f),log(pxx),'.','color','black'); hold on; 
            
            h1=plot(fit1); legend off  
            set(h1,'MarkerEdgeColor','none','marker','.','color','red','LineWidth',2)
            xt=[0.001 0.01 0.1 0.5 2 5 10];    xticks(log(xt));  xlim([log(0.01) log(2)]);
            xticklabels({num2str(xt(1)) ,num2str(xt(2)), num2str(xt(3)), num2str(xt(4)) ,num2str(xt(5)) ,num2str(xt(6)),num2str(xt(7))});
            ax = gca; ax.XGrid = 'on';
            %textLoc(strcat('Exponent = ',num2str(round(fit1.Coefficients.Estimate(2),3))),'NorthEast');
            title '' ; ylabel('Power spectral density (dB/Hz)'); xlabel('Frequency (Hz)')
       end
       
       if PLOT==3  
           subplot(1,2,1)
            plot(log(f),log(pxx),'.','color','black','MarkerSize',3); hold on; 
            h1=plot(fit1); legend off  
            set(h1,'MarkerEdgeColor','none','marker','.','color','red','LineWidth',1)
            xt=[0.001 0.01 0.1 0.5 2 5 10];    xticks(log(xt));  xlim([log(0.01) log(2)]);
            xticklabels({num2str(xt(1)) ,num2str(xt(2)), num2str(xt(3)), num2str(xt(4)) ,num2str(xt(5)) ,num2str(xt(6)),num2str(xt(7))});
            ax = gca; ax.XGrid = 'on';
            %textLoc(strcat('Exponent = ',num2str(round(fit1.Coefficients.Estimate(2),3))),'NorthEast');
            title('Pwelch output') ; ylabel('Power spectral density (dB/Hz)'); xlabel('Frequency (Hz)')
            
            subplot(1,2,2)
            plot(log(fz),log(pxxz),'.','color','black','MarkerSize',8); hold on; 
            h2=plot(fit2); legend off  
            set(h2,'MarkerEdgeColor','none','marker','.','color','red','LineWidth',1)
            xt=[0.001 0.01 0.1 0.5 2 5 10];    xticks(log(xt));  xlim([log(0.01) log(2)]);
            xticklabels({num2str(xt(1)) ,num2str(xt(2)), num2str(xt(3)), num2str(xt(4)) ,num2str(xt(5)) ,num2str(xt(6)),num2str(xt(7))});
            ax = gca; ax.XGrid = 'on';
            ylabel ''; 
            %textLoc(strcat('Exponent = ',num2str(round(fit1.Coefficients.Estimate(2),3))),'NorthEast');
            title('Evenly re-sampled') ; xlabel('Frequency (Hz)')
       end
        
       if PLOT==1
            %subplot(1,2,1); plot(data_in)
            %subplot(1,2,2);     
            plot(log(f(f>=0.02 & f<=2)),log(pxx(f>=0.02 & f<=2)),'.')
            hold on;  plot(fit1); legend off     
            xticks(log([0.05 0.2 0.35  0.5  1]));  xticklabels({'0.05','0.2', '0.35', '0.5','1'}) 
            textLoc(strcat('Exponent = ',num2str(round(fit1.Coefficients.Estimate(2),3))),'NorthEast');
       end
end

