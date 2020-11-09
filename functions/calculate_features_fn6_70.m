function [table_out, names_out ] = calculate_features_fn6_70(data_in,fs,add_str)

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
            max_hyp=quantile(hyp,0.9999999);
            max_hyp_99=quantile(hyp,0.99);
            GEVparams = gevfit(hyp(hyp<max_hyp_99));
            max_hyp_HP=quantile(hyp_HP,0.9999999);
            max_hyp_99_HP=quantile(hyp_HP,0.99);
            GEVparams_HP = gevfit(hyp_HP(hyp_HP<max_hyp_99_HP));
            if 1==1
                subplot(1,2,1)
                hist(hyp_HP(hyp_HP<max_hyp_99_HP))
                subplot(1,2,2)
                x=linspace(min(hyp_HP(hyp_HP<max_hyp_99_HP)),max(hyp_HP(hyp_HP<max_hyp_99_HP)),1000);
                y=gevpdf(x,GEVparams_HP(1),GEVparams_HP(2),GEVparams_HP(3));
                plot(x,y)
                pause; close all
            end
            % Slope of the hyp spectrum
            [he_005_08, he_005_2, he_1_2] = slope_of_spectrum2(hyp,4,0);
            [hpe_005_08, hpe_005_2, hpe_1_2] = slope_of_spectrum2(hyp_HP,4,0);
            
            % Re-project along PC1 and PC2 and resample to 4Hz
            [coeff,score,latent,tsquared,explained,mu] = pca(data_4hz);
            ellipticalness=explained(1)/explained(2);
            [coeff,score,latent,tsquared,explained,mu] = pca(data_4hz_HP); %Use this one going forward
            ellipticalness_HP=explained(1)/explained(2);
            
            magnitude_features=cat(2,max_hyp,max_hyp_HP,max_hyp_99,max_hyp_99_HP,...
                GEVparams(1),GEVparams_HP(1),GEVparams(2),GEVparams_HP(2),GEVparams(3),GEVparams_HP(3),...
                he_005_08, hpe_005_08,he_005_2,hpe_005_2, he_1_2, hpe_1_2,...
                ellipticalness,ellipticalness_HP);
            namesMagnitude={'h_max_hyp','hp_max_hyp','h_max_hyp_99','hp_max_hyp_99',...
                'h_GEV_k','hp_GEV_k','h_GEV_sigma','hp_GEV_sigma','h_GEV_mu','hp_GEV_mu',...
                'h_slope_005_08','hp_slope_005_08','h_slope_005_2','hp_slope_005_2', ...
                'h_slope_1_2','hp_slope_1_2','h_ellipticalness','hp_ellipticalness'};
                  
            data_4hz_projected = score;
            [se_005_08, se_005_2, se_1_2] = slope_of_spectrum2(data_4hz_projected(:,1),4,0); 
            [ce_005_08, ce_005_2, ce_1_2] = slope_of_spectrum2(data_4hz_projected(:,2),4,0);
            
            % Extract peaks using wavelet transform
            [sf0_fq, sf0_w, sf0_h,sf0_D0, snum_pks, ] = find_wavelet_peaks2( data_4hz_projected(:,1),4,0.01,50,0); 
            [cf0_fq, cf0_w, cf0_h,cf0_D0, cnum_pks,] = find_wavelet_peaks2( data_4hz_projected(:,2),4,0.01,50,0); 
            namesAdd={'f0_fq','f0_w','f0_h','f0_D0','num_pks','slope_0005_08','slope_0005_2','slope_1_2'};
            
            stream_featuresAdd=cat(2,sf0_fq,sf0_w,sf0_h,sf0_D0,snum_pks,se_005_08,se_005_2,se_1_2);
            cross_featuresAdd= cat(2,cf0_fq,cf0_w,cf0_h,cf0_D0,cnum_pks,ce_005_08,ce_005_2,ce_1_2);

            % run all Catch 22 features
            [temp_features1 names22] = catch22_all(data_4hz_projected(:,1));
            stream_features22=temp_features1';
            temp_features2 = catch22_all(data_4hz_projected(:,2));
            cross_features22=temp_features2';

            names_out=cat(2,namesMagnitude,strcat('s_',namesAdd),...
                strcat('s_',names22),strcat('c_',namesAdd),strcat('c_',names22));
            features_out=cat(2,magnitude_features,...
                stream_featuresAdd,stream_features22,cross_featuresAdd,cross_features22);
            table_out=table2array(cell2table(num2cell(features_out),'VariableNames',names_out));
        else %end first if nan
            table_out=nan(1,66); 
            names_out=nan(1,66);
        end
    else %end first if nan
        table_out=nan(1,66); 
        names_out=nan(1,66);
    end
end

