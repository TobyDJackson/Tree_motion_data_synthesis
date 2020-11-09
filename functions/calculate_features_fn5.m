function [table_out, names_out ] = calculate_features_fn5(data_in,fs,add_str)

    % This should just calculate features for a single tree with two
    % columns of data using PCA etc

    n=size(data_in,2)/2;
    len_nan=sum(isnan(data_in)==1);
    if len_nan(1)<fs*60*20  % if there are less than 20 mins of NaNs 
        if len_nan(2)<fs*60*20 % in BOTH CHANNELS
            stream_features22=nan(n,22); cross_features22=nan(n,22);
            stream_featuresAdd=nan(n,8); cross_featuresAdd=nan(n,8);
            ellipticalness=nan(n,1);


            data=replace_nan_with_col_mean(data_in);

            % Re-project along PC1 and PC2 and resample to 4Hz

            [coeff,score,latent,tsquared,explained,mu] = pca(data);
            

            ellipticalness=explained(1)/explained(2);
            hyp=hypot(data_in(:,1),data_in(:,2));
            max_hyp=quantile(hyp,0.9999999);
            max_hyp_99=quantile(hyp,0.99);
            %hyp=downsample(hyp(hyp<max_hyp_99),10); Downsamples before GEV fit?
            params = gevfit(hyp(hyp<max_hyp_99));
            if 1==2
                y = linspace(min(hyp),max(hyp),100);
                subplot(1,2,1) 
                h=histogram(hyp);
                subplot(1,2,2)
                p = gevpdf(y,params(1),params(2),params(3));
                line(y,p,'color','r')
             end

            data_projected=score;
            data_4hz_projected=resample(data_projected,4,fs);
            %data_4hz_projected = check_length_and_pad(data_4hz_projected,2400,2300,2500,2); % Check the length of data_4hz and pad (with nan or mean?)
            data_4hz_projected = replace_nan_with_mean(data_4hz_projected);

            % run all features
            [temp_features1 names22] = catch22_all(data_4hz_projected(:,1));
            stream_features22=temp_features1';
            temp_features2 = catch22_all(data_4hz_projected(:,2));
            cross_features22=temp_features2';

            % Extract peaks using wavelet transform
            [sf0_fq, sf0_w, sf0_h,sf0_D0, snum_pks, ] = find_wavelet_peaks2( data_4hz_projected(:,1),4,0.01,50,0); 
            [cf0_fq, cf0_w, cf0_h,cf0_D0, cnum_pks,] = find_wavelet_peaks2( data_4hz_projected(:,2),4,0.01,50,0); 
            [se_005_08, se_005_2, se_1_2] = slope_of_spectrum2(data_4hz_projected(:,1),4,0); 
            [ce_005_08, ce_005_2, ce_1_2] = slope_of_spectrum2(data_4hz_projected(:,2),4,0);


             stream_featuresAdd=cat(2,sf0_fq,sf0_w,sf0_h,sf0_D0,snum_pks,se_005_08,se_005_2,se_1_2);
             cross_featuresAdd= cat(2,cf0_fq,cf0_w,cf0_h,cf0_D0,cnum_pks,ce_005_08,ce_005_2,ce_1_2);


            namesAdd={'f0_fq','f0_w','f0_h','f0_D0','num_pks','slope_0005_08','slope_0005_2','slope_1_2'};
            names_out=cat(2,'ellipticalness','max_hyp','max_hyp_99','GEV_k','GEV_sigma','GEV_mu',...
                strcat('s_',names22), strcat('s_',namesAdd),strcat('c_',names22),strcat('c_',namesAdd));
            features_out=cat(2,ellipticalness,max_hyp,max_hyp_99,params(1),params(2),params(3),...
                stream_features22,stream_featuresAdd,cross_features22,cross_featuresAdd);
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

