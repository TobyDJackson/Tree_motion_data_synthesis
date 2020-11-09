function [table_out, names_out ] = calculate_features_fn_singleChannel(data_in,fs,add_str)

    % This should just calculate features for a single tree with two
    % columns of data using PCA etc
    % I have added some 'magnitude features' with and without HighPass
    % I have put the f0 and slope features 'Add' in front of catch22
    % I have defaulted to HighPass rather than not, because it is better

    n=size(data_in,2)/2;
    len_nan=sum(isnan(data_in)==1);
    if len_nan(1)<fs*60*20  % if there are less than 20 mins of NaNs 
        if len_nan(2)<fs*60*20 % in EITHER CHANNEL
            
            data=replace_nan_with_col_mean(data_in);
            data_4hz=resample(data,4,fs);
            lower_frequency_threshold=0.0017; % this is ten minutes
            [b2,a2]       = butter(4,lower_frequency_threshold / 2,'high');
            data_4hz_HP= filtfilt(b2,a2,data); % High Pass Filter

            % Calculate maxima and extreme value distribution parameters
            % with and without HighPass filtering
            hyp=hypot(data_4hz(:,1),data_4hz(:,2));
            hyp_HP=hypot(data_4hz_HP(:,1),data_4hz_HP(:,2));
            a=data_4hz_HP(:,1); b=data_4hz_HP(:,2);
            max_a=quantile(a,0.9999999);
            max_99_a=quantile(a,0.99);
            GEVparams_a = gevfit(a(a<max_99_a));
            max_b=quantile(b,0.9999999);
            max_99_b=quantile(b,0.99);
            GEVparams_b = gevfit(b(b<max_99_b));
            
            % Slope of the hyp spectrum
            [he_005_08, he_005_2, he_1_2] = slope_of_spectrum2(hyp,4,0);
            [hpe_005_08, hpe_005_2, hpe_1_2] = slope_of_spectrum2(hyp_HP,4,0);
            
            % Re-project along PC1 and PC2 and resample to 4Hz
            [coeff,score,latent,tsquared,explained,mu] = pca(data_4hz);
            ellipticalness=explained(1)/explained(2);
            [coeff,score,latent,tsquared,explained,mu] = pca(data_4hz_HP); %Use this one going forward
            ellipticalness_HP=explained(1)/explained(2);
            
            magnitude_features=cat(2,max_a,max_b,max_99_a,max_99_b,...
                GEVparams_a(1),GEVparams_b(1),GEVparams_a(2),GEVparams_b(2),GEVparams_a(3),GEVparams_b(3));
            namesMagnitude={'max_a','max_b','max_99_a','max_99_b',...
                'GEVa_k','GEVb_k','GEVa_sigma','GEVb_sigma','GEVa_mu','GEVb_mu'};
                  
            names_out=namesMagnitude;
            features_out=magnitude_features;
            table_out=table2array(cell2table(num2cell(features_out),'VariableNames',names_out));
        else %end first if nan
            table_out=nan(1,10); 
            names_out=nan(1,10);
        end
    else %end first if nan
        table_out=nan(1,10); 
        names_out=nan(1,10);
    end
end

