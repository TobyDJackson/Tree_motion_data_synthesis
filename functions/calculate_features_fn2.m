function [table_out, data_4hz_projected_save ] = ...
    calculate_features_fn2(dataPath,TT_in,good_rows,name_in)

    n=height(TT_in); 
    stream_features22=nan(n,22); cross_features22=nan(n,22);
    stream_featuresAdd=nan(n,8); cross_featuresAdd=nan(n,8);
    shape_metrics=nan(n,6);
    
    SAVE_PROJECTED_4HZ=0;
    if SAVE_PROJECTED_4HZ==1
        data_4hz_projected_save=nan(14400,2*n);
    end


    % Loop over the files and calculate features
    for j = 1:length(good_rows)
        i=good_rows(j)
        %i
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
            data = importfile_SpectralAnalysis(strcat(dataPath,'\',this_file.name));
            data = replace_nan_with_mean(data);
            %[sf0_fq] = find_wavelet_peaks2( data(:,1),16,0.01,50,0)
         
            disp(length(data)./(TT_in.Res_Hz(i)*60*60))
            
            if 1==1 % HighPass filter       
                Nyf = 0.5*TT_in.Res_Hz(i); % Nyquist-frequency (Hz)    
                lower_frequency_threshold=0.0017; % this is ten minutes
                fOrder        = 4;  
                [b2,a2]       = butter(fOrder,lower_frequency_threshold / Nyf,'high');
                data_test = filtfilt(b2,a2,data);
                %subplot(2,1,1); plot(data(:,1))
                %subplot(2,1,2); plot(data_test(:,1)) 
                %pause; close all; 
                data=data_test;
            end
            
            % Re-project and resample
            
            [coeff,score,latent,tsquared,explained,mu] = pca(data);
            if 1==2               
                subplot(1,2,1)
                %biplot(coeff); hold on; 
                plot(data_test(:,1),data_test(:,2),'.')
                %axis([-0.2 0.2 -0.2 0.2])
                subplot(1,2,2)
                plot(score(:,1),score(:,2),'.')
                %axis([-0.2 0.2 -0.2 0.2])
                pause; close all
            end
            shape_metrics(i,1)=explained(1)/explained(2);
            data_projected=data;
            data_4hz = resample(data_projected,4,TT_in.Res_Hz(i));
            data_4hz = check_length_and_pad(data_4hz,14400,14300,14500,2); % Check the length of data_4hz and pad (with nan or mean?)
            data_4hz = replace_nan_with_mean(data_4hz);

            % calculate resultant motion, the maximum and the shape of a
            % Generalized Extreme Value distribution
            hyp=hypot(data_4hz(:,1),data_4hz(:,2));
            shape_metrics(i,2)=quantile(hyp,0.9999999);
            shape_metrics(i,3)=quantile(hyp,0.99);
            params = gevfit(hyp(hyp<quantile(hyp,0.99)));
            shape_metrics(i,4:6)=cat(2,params(1),params(2),params(3));

            data_projected_PCA=score;
            data_4hz_projected_PCA = resample(data_projected_PCA,4,TT_in.Res_Hz(i));
            data_4hz_projected_PCA = check_length_and_pad(data_4hz_projected_PCA,14400,14300,14500,2); % Check the length of data_4hz and pad (with nan or mean?)
            data_4hz_projected_PCA = replace_nan_with_mean(data_4hz_projected_PCA);
            
            if SAVE_PROJECTED_4HZ==1
                data_4hz_projected_save(1:14400,2*i-1:2*i)=data_4hz; 
            end
        end

        % run all features
        [temp_features1, names22] = catch22_all(data_4hz(:,1));
        stream_features22(i,1:22)=temp_features1';
        temp_features2 = catch22_all(data_4hz(:,2));
        cross_features22(i,1:22)=temp_features2';

        if 1==1 % may need a 'try' function

            [sf0_fq, sf0_w, sf0_h,sf0_D0, snum_pks, ] = find_wavelet_peaks2( data_4hz_projected_PCA(:,1),4,0.01,50,0); 
            [cf0_fq, cf0_w, cf0_h,cf0_D0, cnum_pks,] = find_wavelet_peaks2( data_4hz_projected_PCA(:,2),4,0.01,50,0); 
            disp(sf0_fq);
            [se_005_08, se_005_2, se_1_2] = slope_of_spectrum2(data_4hz_projected_PCA(:,1),4,1); 
            [ce_005_08, ce_005_2, ce_1_2] = slope_of_spectrum2(data_4hz_projected_PCA(:,2),4,0);
             pause; close all;
            stream_featuresAdd(i,1:8)=cat(2,sf0_fq,sf0_w,sf0_h,sf0_D0,snum_pks,se_005_08,se_005_2,se_1_2);
            cross_featuresAdd(i,1:8)= cat(2,cf0_fq,cf0_w,cf0_h,cf0_D0,cnum_pks,ce_005_08,ce_005_2,ce_1_2);
            
            namesAdd={'f0_fq','f0_w','f0_h','f0_D0','num_pks','slope_0005_08','slope_0005_2','slope_1_2'};
              %disp(featuresAdd(i,:))
            %pause; close all

        end

    end

if 1==1
    %features_out=cat(2,features22,featuresAdd);
    names_shape_metrics={'ellipticalness','max_hyp','max_hyp_99','GEV_k','GEV_sigma','GEV_mu'};
    names_out=cat(2, strcat(name_in,'_',names_shape_metrics),...
            strcat(name_in,'_s_',names22), strcat(name_in,'_s_',namesAdd), ...
            strcat(name_in,'_c_',names22) , strcat(name_in,'_c_',namesAdd));
    
    features_out=cat(2,shape_metrics,stream_features22,stream_featuresAdd,cross_features22,cross_featuresAdd);
  

    table_out=cell2table(num2cell(features_out),'VariableNames',names_out);

end


end

