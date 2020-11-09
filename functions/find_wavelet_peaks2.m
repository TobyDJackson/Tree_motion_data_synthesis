function [f0_fq, f0_w, f0_h,f0_D0,  num_pks] = find_wavelet_peaks2( data_in, fs, min_peak_height,max_peak_width,PLOT )

   % This function calculaes the global wavelet spectrum and looks for
   % peaks in it. I have hard-coded it to select the highest peak within
   % some frequency limits relevant to the fundamental frequency of tree sway
    dark2=brewermap(8,'dark2');
    data_in=data_in(isnan(data_in)==0);
    
    [coeffs1,wfreq,coi1] = cwt(data_in, 'amor',fs);%,'NumOctaves',12,'VoicesPerOctaves',16);  % I need to test the sensitivity to these two parameters 
    wspec1    = abs(coeffs1).^2;                      % Wavelet power spectrum measured data
    glowspec1 = sum(wspec1,2);                        % Global wavelet spectrum measured data
    y=5.*glowspec1./(max(glowspec1)-min(glowspec1));
    
    [pks,locs,w,p] = findpeaks(y,'MinPeakProminence',min_peak_height,'MaxPeakWidth',max_peak_width,'Annotate','extents');
    a=[pks,locs,w,p];
    pk_wfreq=wfreq(locs);
    a(pk_wfreq<0.01,:)=[]; % delete frequencies below 0.01 - they are pretty noisy
    num_pks=size(a,1);
    b=a(wfreq(a(:,2))>0.05 & wfreq(a(:,2))<3,:); % search for f0 in between 0.05 and 3 Hz
    f0_h= b(   b(:,4)==max(b(:,4))  ,1); % Find the height of the most prominent peak in that frequency range for f0
    f0_w= b(   b(:,4)==max(b(:,4))  ,3); % Width
    f0_fq=wfreq(b(   b(:,4)==max(b(:,4))  ,2)); %Frequency
    f0_D0=f0_h./sum(a(:,1)); % Dominance of this peak within >0.01 frequency range.
    
    if length(f0_fq)==0; f0_fq=NaN; end
    if length(f0_h)==0; f0_h=NaN; end
    if length(f0_w)==0; f0_w=NaN; end
    if length(f0_D0)==0; f0_D0=NaN; end
    if length(num_pks)==0; num_pks=NaN; end
    
    
       
    if PLOT==1
        %%
        dark2=brewermap(8,'dark2'); 
        findpeaks(y,'MinPeakProminence',min_peak_height,'MaxPeakWidth',max_peak_width,'Annotate','extents');
        hold on;
       
        
        %semilogx(wfreq_tree,spectrum_tree,'color',color_in,'LineWidth',1.2,'LineStyle',LineStyle); hold on
        %plot(log(wfreq),y,'color',dark2(1,:),'LineWidth',1.2);  grid off; hold on;
        %semilogx(pk_wfreq,pks,'+','MarkerSize',20,'color','red')
        %semilogx(f0_fq,f0_h,'o','MarkerSize',20,'color','red')
        xlabel('Hz');ylabel('GWV');      legend off;      
        xlabel('Frequency Hz');   legend off;  grid off; 
        xt=[0.001 0.01 0.1 0.5 2 5 10];    xticks(log(xt));  %xlim([(0.001) (10)]);
        %xt=[0.001 0.01 0.1 0.5 2 5 10];    xticks(log(xt));  %xlim([log(0.001) log(10)]);
        xticklabels({num2str(xt(1)) ,num2str(xt(2)), num2str(xt(3)), num2str(xt(4)) ,num2str(xt(5)) ,num2str(xt(6)),num2str(xt(7))});
        grid on;
        hold off
        %%
    end
    
    if PLOT==2
        len=length(data_in);
        [coeffs1,wfreq_short,coi1] = cwt(data_in(1:len/3), 'amor',fs);
        y1=5.*sum(abs(coeffs1).^2,2)./(max(sum(abs(coeffs1).^2,2))-min(sum(abs(coeffs1).^2,2)));
        
        [coeffs1,wfreq_short,coi1] = cwt(data_in(len/3:2*len/3), 'amor',fs);
        y2=5.*sum(abs(coeffs1).^2,2)./(max(sum(abs(coeffs1).^2,2))-min(sum(abs(coeffs1).^2,2)));
        
        [coeffs1,wfreq_short,coi1] = cwt(data_in(2*len/3:end), 'amor',fs);
        y3=5.*sum(abs(coeffs1).^2,2)./(max(sum(abs(coeffs1).^2,2))-min(sum(abs(coeffs1).^2,2)));
        y_mean=mean(cat(2,y1,y2,y3),2);
        
        subplot(2,2,1)
        semilogx(wfreq_short,y1,'color',dark2(1,:),'LineWidth',1.2);  grid off; hold on;
        semilogx(wfreq_short,y2,'color',dark2(2,:),'LineWidth',1.2); 
        semilogx(wfreq_short,y3,'color',dark2(3,:),'LineWidth',1.2); 
        xlabel('Hz');ylabel('GWV');      legend off;      
        xt=[0.001 0.01 0.1 0.5 2 5 10];    xticks(log(xt));  xlim([(0.001) (10)]);
        xticklabels({num2str(xt(1)) ,num2str(xt(2)), num2str(xt(3)), num2str(xt(4)) ,num2str(xt(5)) ,num2str(xt(6)),num2str(xt(7))}); grid on;
        
        
        subplot(2,2,2)
        semilogx(wfreq_short,y_mean,'color',dark2(1,:),'LineWidth',1.2);  grid off; hold on;
        xlabel('Hz');ylabel('GWV');      legend off;      
        xt=[0.001 0.01 0.1 0.5 2 5 10];    xticks((xt));  xlim([(0.001) (10)]);
        xticklabels({num2str(xt(1)) ,num2str(xt(2)), num2str(xt(3)), num2str(xt(4)) ,num2str(xt(5)) ,num2str(xt(6)),num2str(xt(7))}); grid on;
        
        subplot(2,2,3)
        semilogx(wfreq,y,'color',dark2(1,:),'LineWidth',1.2);  grid off; hold on;
        xlabel('Hz');ylabel('GWV');      legend off;      
        xt=[0.001 0.01 0.1 0.5 2 5 10];    xticks((xt));  xlim([(0.001) (10)]);
        xticklabels({num2str(xt(1)) ,num2str(xt(2)), num2str(xt(3)), num2str(xt(4)) ,num2str(xt(5)) ,num2str(xt(6)),num2str(xt(7))}); grid on;
        
        subplot(2,2,4)
        findpeaks(y,'MinPeakProminence',min_peak_height,'MaxPeakWidth',max_peak_width,'Annotate','extents');
        legend off;
        pause; close all;
        %%
    end
end

