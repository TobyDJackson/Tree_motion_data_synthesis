function [ peak_frequencies, width, prominence f log_pxx] = find_res_peaks( data_in, fs, min_peak_height,PLOT )
% Just a quick function that tidies up scripts and keeps all the parameters
% together.
    
    data_in=data_in(isnan(data_in)==0);
    [pxx,f] = pwelch(data_in,[],[],[],fs);
    log_pxx=10*log10(pxx); 
    test_format=smooth(log_pxx-Running_mode(log_pxx,20),200);
       
    power=log_pxx-smooth(log_pxx,length(log_pxx)/2);
    power_test=test_format-smooth(test_format,length(test_format)/2);
    %short_smooth=length(power)/250;
     [peak_heights,peak_frequencies, width, prominence] = findpeaks(power_test,f,'MinPeakProminence',min_peak_height);
    % [peak_heights,peak_frequencies, width, prominence] = findpeaks(smooth(power,length(power)/250),f,'MinPeakProminence',min_peak_height);
   
    if PLOT==1
        subplot(1,2,1)
        plot(f,log_pxx); grid on;ax1=axis; axis([0 0.5 ax1(3) ax1(4)])
        title('Unsmoothed Periodogram');  xlabel('Frequency (Hz)');  ylabel('Power (arbitrary units)')
        
        subplot(1,2,2)
       % findpeaks(smooth(power,length(power)/250),f,'MinPeakProminence',min_peak_height)
        findpeaks(power_test,f,'MinPeakProminence',min_peak_height,'Annotate','extents')
        title('Smoothed Periodogram'); xlabel('Frequency (Hz)');  ylabel('Power (arbitrary units)');
        ax2=axis; axis([0 0.5 ax2(3) ax2(4)]); legend off
    end
    %disp(peaks');


end

