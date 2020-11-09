function [max_pk_fq pk_fq] = find_wavelet_peaks( data_in, fs, min_peak_height,max_peak_width,PLOT )

   % This function calculaes the global wavelet spectrum and looks for
   % peaks in it. I have hard-coded it to select the highest peak within
   % some frequency limits relevant to the fundamental frequency of tree sway
   
    data_in=data_in(isnan(data_in)==0);

    [coeffs1,wfreq,coi1] = cwt(data_in, 'amor',fs);%,'NumOctaves',12,'VoicesPerOctaves',16);  % I need to test the sensitivity to these two parameters 
    wspec1    = abs(coeffs1).^2;                      % Wavelet power spectrum measured data
    glowspec1 = sum(wspec1,2);                        % Global wavelet spectrum measured data
    y=5.*glowspec1./(max(glowspec1)-min(glowspec1));
    
       
    [pks,locs,w,p] = findpeaks(y,'MinPeakProminence',min_peak_height,'MaxPeakWidth',max_peak_width,'Annotate','extents');
    a=[pks,locs,w,p];
    pk_fq=wfreq(locs);
    b=a(wfreq(a(:,2))>0.05 & wfreq(a(:,2))<3,:);
    max_pk_h= b(   b(:,4)==max(b(:,4))  ,1);
    max_pk_loc= b(   b(:,4)==max(b(:,4))  ,2);
    max_pk_fq=wfreq(max_pk_loc);
    
    if length(max_pk_fq)==0; max_pk_fq=NaN; end

    if PLOT==1
        %%
        %findpeaks(y,'MinPeakProminence',min_peak_height,'MaxPeakWidth',max_peak_width,'Annotate','extents');
        color1=brewermap(8,'dark2');
        semilogx(wfreq,y,'color',color1(1,:),'LineWidth',1.2);  grid off; hold on;
        semilogx(pk_fq,pks,'+','MarkerSize',20,'color','red')
        semilogx(max_pk_fq,max_pk_h,'o','MarkerSize',20,'color','red')
        xlabel('Hz');ylabel('GWV');      legend off;      
        xt=[0.001 0.01 0.1 0.5 2 5 10];    xticks((xt));  xlim([(0.001) (10)]);
        xticklabels({num2str(xt(1)) ,num2str(xt(2)), num2str(xt(3)), num2str(xt(4)) ,num2str(xt(5)) ,num2str(xt(6)),num2str(xt(7))});
        grid on;
        %%
    end
    
end

