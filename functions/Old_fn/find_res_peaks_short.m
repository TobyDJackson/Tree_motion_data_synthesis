



function [ peak_frequencies_model,  peak_frequencies_field , f , log_pxx] = find_res_peaks_short( data_in, fs, min_peak_height )
% Just a quick function that tidies up scripts and keeps all the parameters
% together.
    
    data_in_filtered=data_in(isnan(data_in(:,1))==0,:);
    [pxx,f] = pwelch(data_in_filtered,[],[],[],fs);
    
    %%
    subplot(2,2,[1 3])
    log_pxx=10*log10(pxx);
    plot(f,log_pxx)
    
    title('Unsmoothed Periodograms')
    legend('Model spectrum', 'Field spectrum'); legend boxoff
    xlabel('Frequency (Hz)')
    ylabel('Power (arbitrary units)')
    ax1=axis; axis([0 2 ax1(3) ax1(4)])
    

    %%

    subplot(2,2,4)
    test_model=running_max_new(log_pxx(:,1),5);
    test_model=test_model'-smooth(running_max_new(log_pxx(:,1),5),1000);
    test_model=smooth(test_model,15);   
    findpeaks(test_model,f,'MinPeakProminence',min_peak_height,'Annotate','extents')
    title('Model - Smoothed Periodogram')
    xlabel('Frequency (Hz)')
    ylabel('Power (arbitrary units)')
    legend off
    [peak_heights_model,peak_frequencies_model] = findpeaks(test_model,f,'MinPeakProminence',min_peak_height);
    
    %%
    subplot(2,2,2)
    test_field=running_max_new(log_pxx(:,2),5);
    test_field=test_field'-smooth(running_max_new(log_pxx(:,2),5),1000);
    test_field=smooth(test_field,15);   
    findpeaks(test_field,f,'MinPeakProminence',min_peak_height,'Annotate','extents')
    title('Field - Smoothed Periodogram')
    xlabel('Frequency (Hz)')
    ylabel('Power (arbitrary units)')
    legend off
    [peak_heights_field,peak_frequencies_field] = findpeaks(test_field,f,'MinPeakProminence',min_peak_height);

end

    %test_format=smooth(log_pxx-Running_mode(log_pxx,20),200);
    %test_format=log_pxx-Running_mode(log_pxx,5);
    %test_format=smooth(test_format,10);
        %power=log_pxx-smooth(log_pxx,length(log_pxx)/2);
    %power=log_pxx-smooth(log_pxx,length(log_pxx)/2);
    %power_test=test_format-smooth(test_format,length(test_format)/2);
    %short_smooth=length(power)/250;