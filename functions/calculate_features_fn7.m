function [table_out, names_out ] = calculate_features_fn7(dataPath,TT_in,good_rows,name_in)

    %data_in,fs,add_str
    % This should calculate features for a list of trees with two
    % columns of data using PCA etc
    % I have added some 'magnitude features' with and without HighPass
    % I have put the f0 and slope features 'Add' in front of catch22
    % I have defaulted to HighPass rather than not, because it is better


    n=height(TT_in); 
    stream_features22=nan(n,22); cross_features22=nan(n,22);
    stream_featuresAdd=nan(n,8); cross_featuresAdd=nan(n,8);
    magnitude_features=nan(n,18);
    
    for j = 1:length(good_rows)
        i=good_rows(j)
        disp(strcat('j = ' ,num2str(j), ' / ',num2str(length(good_rows))))
        %[author]_[site]_[tree]_[res]_[sensor]_[duration]_[condition]_[wind]
        filename=char(TT_in.Filename(i));
        underscores=strfind(filename,'_');
        %new_filename=strcat(filename(1:underscores(5)),duration,filename(underscores(5)+4:end));
        new_filename=filename(1:underscores(5));
        this_file=dir(strcat(dataPath,'\',new_filename,'*'));
        disp(this_file.name)
        if length(this_file)~=1;  % if the file isn't found
            disp('cant find file'); pause; continue; 
        else
            % Import the data & check length
            data_in = importfile_SpectralAnalysis(strcat(dataPath,'\',this_file.name));
            data_in = replace_nan_with_mean(data_in);         
            disp(length(data_in)./(TT_in.Res_Hz(i)*60*60))
            
            fs=TT_in.Res_Hz(i); % Sampling frequency
            data=replace_nan_with_col_mean(data_in);
            
            plot_key_features(data,fs);
            %pause; 
            saveas(gcf,strcat(TT_in.Filename(i),'.png'))
        
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

            % Slope of the hyp spectrum
            [he_005_08, he_005_2, he_1_2] = slope_of_spectrum2(hyp,4,0);
            [hpe_005_08, hpe_005_2, hpe_1_2] = slope_of_spectrum2(hyp_HP,4,0);

            % Re-project along PC1 and PC2 and resample to 4Hz
            [coeff,score,latent,tsquared,explained,mu] = pca(data_4hz);
            ellipticalness=explained(1)/explained(2);
            [coeff,score,latent,tsquared,explained,mu] = pca(data_4hz_HP); %Use this one going forward
            ellipticalness_HP=explained(1)/explained(2);

            magnitude_features(i,:)=cat(2,max_hyp,max_hyp_HP,max_hyp_99,max_hyp_99_HP,...
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

            stream_featuresAdd(i,:)=cat(2,sf0_fq,sf0_w,sf0_h,sf0_D0,snum_pks,se_005_08,se_005_2,se_1_2);
            cross_featuresAdd(i,:)= cat(2,cf0_fq,cf0_w,cf0_h,cf0_D0,cnum_pks,ce_005_08,ce_005_2,ce_1_2);

            % run all Catch 22 features
            [temp_features1 names22] = catch22_all(data_4hz_projected(:,1));
            stream_features22(i,:)=temp_features1';
            temp_features2 = catch22_all(data_4hz_projected(:,2));
            cross_features22(i,:)=temp_features2';

        end % End if file ~=1 statement
    end % End loop over trees
    names_out=cat(2,strcat(name_in,'_',namesMagnitude),strcat(name_in,'_s_',namesAdd),...
                strcat(name_in,'_s_',names22),strcat(name_in,'_c_',names22));
    features_out=cat(2,magnitude_features,...
                stream_featuresAdd,stream_features22,cross_features22);
    table_out=cell2table(num2cell(features_out),'VariableNames',names_out);
  
end

