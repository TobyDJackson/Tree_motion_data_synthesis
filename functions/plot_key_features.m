function [h1] = plot_key_features(data_in,fs,add_str)


    n=size(data_in,2)/2;
    len_nan=sum(isnan(data_in)==1);
    if len_nan(1)<fs*60*20  % if there are less than 20 mins of NaNs 
        if len_nan(2)<fs*60*20 % in EITHER CHANNEL
            
            data=replace_nan_with_col_mean(data_in);
            data_4hz=resample(data,4,fs);
            lower_frequency_threshold=0.0017; % this is ten minutes
            [b2,a2]       = butter(4,lower_frequency_threshold / 2,'high');
            data_4hz_HP= filtfilt(b2,a2,data); % High Pass Filter
            
            subplot(2,3,1)
            h1=plot(data_4hz(1:1000,1))
            title('Data sample')
            subplot(2,3,4)
            plot(data_4hz_HP(1:1000,2))
            title('Data sample - HP')
            
            % Calculate maxima and extreme value distribution parameters
            % with and without HighPass filtering
            hyp=hypot(data_4hz(:,1),data_4hz(:,2));
            hyp_HP=hypot(data_4hz_HP(:,1),data_4hz_HP(:,2));
            max_hyp_HP=quantile(hyp_HP,0.9999999);
            max_hyp_99_HP=quantile(hyp_HP,0.99);
            GEVparams_HP = gevfit(hyp_HP(hyp_HP<max_hyp_99_HP));
            subplot(2,3,5)
            hist(hyp_HP(hyp_HP<max_hyp_99_HP))
            title('Histogram of data')
            subplot(2,3,2)
            x=linspace(0,max_hyp_99_HP,50); 
            plot(x,gevpdf(x,GEVparams_HP(1),GEVparams_HP(2),GEVparams_HP(3)),'color','black','linewidth',1.4)
            title('Extreme value fit')
            subplot(2,3,3)
            [hpe_005_08, hpe_005_2, hpe_1_2] = slope_of_spectrum2(hyp_HP,4,1);
            title('Welchs spectrum slope')
            
            [coeff,score,latent,tsquared,explained,mu] = pca(data_4hz_HP); %Use this one going forward
            ellipticalness_HP=explained(1)/explained(2);
            data_4hz_projected = score;
            
            subplot(2,3,6)
            % Extract peaks using wavelet transform
            [sf0_fq, sf0_w, sf0_h,sf0_D0, snum_pks, ] = find_wavelet_peaks2( data_4hz_projected(:,1),4,0.01,50,1); 
            title('Wavelet peaks')

        end
    end
end

