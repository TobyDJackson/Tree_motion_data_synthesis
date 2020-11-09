function [ peak_frequencies, width, prominence] = smooth_res_peaks( pxx, f, min_peak_height,PLOT )
% Just a quick function that tidies up scripts and keeps all the parameters
% together.

log_pxx=10*log10(pxx); 
%plot(log_pxx)
%hold on

log_pxx_flattened=log_pxx-smooth(log_pxx,length(log_pxx)/2);
%plot(log_pxx_flattened)
%hold on
log_pxx_smoothed=smooth(log_pxx_flattened,50);
%plot(log_pxx_smoothed)
[peak_heights,peak_frequencies, width, prominence] = findpeaks(log_pxx_smoothed,f,'MinPeakProminence',min_peak_height);

    if PLOT==1
        subplot(2,2,3)
        plot(f,log_pxx)
        title('Unsmoothed Periodogram')
        xlabel('Frequency (Hz)')
        ylabel('Power (arbitrary units)')
        ax1=axis; axis([0 2 ax1(3) ax1(4)])
        subplot(2,2,4)
        %findpeaks(smooth(power,length(power)/250),f,'MinPeakProminence',min_peak_height)
        findpeaks(log_pxx_smoothed,f,'MinPeakProminence',min_peak_height,'Annotate','extents')
        title('Smoothed Periodogram')
        xlabel('Frequency (Hz)')
        ylabel('Power (arbitrary units)')
        legend off
        ax2=axis; axis([0 2 ax2(3) ax2(4)])
    end
   
end
 %test_format=smooth(log_pxx-Running_mode(log_pxx,20),200);
%plot(test_format)
%power_test=test_format-smooth(test_format,length(test_format)/2);
%plot(power_test)
%short_smooth=length(power)/250;
%[peak_heights,peak_frequencies] = findpeaks(smooth(power,length(power)/250),f,'MinPeakProminence',min_peak_height);


%load('sonic_int.mat')
%sonic_hour_4hz=sonic_int(1:14400,:);
%[pxx_wind,f_wind] = pwelch(sonic_hour_4hz(:,4),[],[],[],4);
%smooth_log_pxx=smooth(10*log10(pxx_wind)-100,20); 
%log_pxx=log_pxx(:,1)-smooth_log_pxx;