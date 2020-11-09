function [table_out, names_out ] = calculate_features_fn3(data_in,fs)

    n=size(data_in,2)/2;
    stream_features22=nan(n,22); cross_features22=nan(n,22);
    stream_featuresAdd=nan(n,8); cross_featuresAdd=nan(n,8);
    shape_metrics=nan(n,6);
    
     % Loop over the cols of data
    for i = 1:n
        a=2*(i-1)+1; b=2*i;
        data=data_in(:,[a b]);
        % Re-project along PC1 and PC2 and resample to 4Hz
        [coeff,score,latent,tsquared,explained,mu] = pca(data);
        shape_metrics(i,1)=explained(1)/explained(2);
        data_projected=score;
        data_4hz_projected=resample(data_projected,4,fs);
        %data_4hz_projected = check_length_and_pad(data_4hz_projected,2400,2300,2500,2); % Check the length of data_4hz and pad (with nan or mean?)
        data_4hz_projected = replace_nan_with_mean(data_4hz_projected);
        hyp=hypot(data_4hz_projected(:,1),data_4hz_projected(:,2));
        shape_metrics(i,2)=quantile(hyp,0.9999999);
        shape_metrics(i,3)=quantile(hyp,0.99);
        params = gevfit(hyp(hyp<max_hyp_99));
        shape_metrics(i,4:6)=cat(2,params(1),params(2),params(3));

        % run all features
        [temp_features1 names22] = catch22_all(data_4hz_projected(:,1));
        stream_features22(i,1:22)=temp_features1';
        temp_features2 = catch22_all(data_4hz_projected(:,2));
        cross_features22(i,1:22)=temp_features2';

        % Extract peaks using wavelet transform
        [sf0_fq, sf0_w, sf0_h,sf0_D0, snum_pks, ] = find_wavelet_peaks2( data_4hz_projected(:,1),4,0.01,50,0); 
        [cf0_fq, cf0_w, cf0_h,cf0_D0, cnum_pks,] = find_wavelet_peaks2( data_4hz_projected(:,2),4,0.01,50,0); 
        [se_005_08 se_005_2 se_1_2] = slope_of_spectrum2(data_4hz_projected(:,1),4,0); 
        [ce_005_08 ce_005_2 ce_1_2] = slope_of_spectrum2(data_4hz_projected(:,2),4,0);
            
         stream_featuresAdd(i,1:8)=cat(2,sf0_fq,sf0_w,sf0_h,sf0_D0,snum_pks,se_005_08,se_005_2,se_1_2);
         cross_featuresAdd(i,1:8)= cat(2,cf0_fq,cf0_w,cf0_h,cf0_D0,cnum_pks,ce_005_08,ce_005_2,ce_1_2);
            

    end % end loop over trees
    
    if 1==1
        %features_out=cat(2,features22,featuresAdd);
        namesAdd={'f0_fq','f0_w','f0_h','f0_D0','num_pks','slope_0005_08','slope_0005_2','slope_1_2'};
          
        %disp(featuresAdd(i,:))
        %pause; close all
        names_out=cat(2, 'ellipticalness','max_hyp','max_hyp_99','GEV_k','GEV_sigma','GEV_mu',...
                strcat('s_',names22), strcat('s_',namesAdd),strcat('c_',names22) , strcat('c_',namesAdd));
        features_out=cat(2,shape_metrics,stream_features22,stream_featuresAdd,cross_features22,cross_featuresAdd);
        table_out=reshape(features_out,[1 size(features_out,1)*size(features_out,2)]);
        %table_out=cell2table(num2cell(features_out),'VariableNames',names_out);
    end
end

