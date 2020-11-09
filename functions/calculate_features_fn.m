function [table_out, data_4hz_projected_save ] = ...
    calculate_features_fn(dataPath,TT_in,good_rows,name_in)

    n=height(TT_in); 
    stream_features22=nan(n,22); cross_features22=nan(n,22);
    stream_featuresAdd=nan(n,4); cross_featuresAdd=nan(n,4);
    
    SAVE_PROJECTED_4HZ=0;
    if SAVE_PROJECTED_4HZ==1
        data_4hz_projected_save=nan(14400,2*n);
    end


    % Loop over the files and calculate features
    for j = 1:length(good_rows)
        i=good_rows(j)
        %i
        disp(strcat('i = ' ,num2str(i), ' / ',num2str(n)))
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

            disp(length(data)./(TT_in.Res_Hz(i)*60*60))
            % Re-project and resample
            [coeff,score,latent,tsquared,explained,mu] = pca(data);
            data_projected=score;
            data_4hz_projected=resample(data_projected,4,TT_in.Res_Hz(i));
            data_4hz_projected = check_length_and_pad(data_4hz_projected,14400,14300,14500,2); % Check the length of data_4hz and pad (with nan or mean?)
            data_4hz_projected = replace_nan_with_mean(data_4hz_projected);
            
            if SAVE_PROJECTED_4HZ==1
                data_4hz_projected_save(1:14400,2*i-1:2*i)=data_4hz_projected; 
            end
        end

        % run all features
        [temp_features1 names22] = catch22_all(data_4hz_projected(:,1));
        stream_features22(i,1:22)=temp_features1';
        temp_features2 = catch22_all(data_4hz_projected(:,2));
        cross_features22(i,1:22)=temp_features2';

        if 1==1 % may need a 'try' function

            % Extract peaks using wavelet transform
            stream_pk_fq_4hz = find_wavelet_peaks( data_4hz_projected(:,1),4,0.01,50,0); %figure
            %subplot(1,2,1)
            stream_pk_fq     = find_wavelet_peaks( data_projected(:,1),TT_in.Res_Hz(i),0.01,50,0);
            cross_pk_fq_4hz = find_wavelet_peaks( data_4hz_projected(:,2),4,0.01,50,0);
            cross_pk_fq     = find_wavelet_peaks( data_projected(:,2),TT_in.Res_Hz(i),0.01,50,0);
            %pause; close all

            % Calculate slope of the spectrum
            stream_slope_4hz = slope_of_spectrum(data_4hz_projected(:,1),4,0.05,0.8,'off',0);
            %subplot(1,2,2)
            stream_slope     = slope_of_spectrum(data_projected(:,1),TT_in.Res_Hz(i),0.05,0.8,'off',0);
            cross_slope_4hz = slope_of_spectrum(data_4hz_projected(:,2),4,0.05,0.8,'off',0);
            cross_slope     = slope_of_spectrum(data_projected(:,2),TT_in.Res_Hz(i),0.05,0.8,'off',0);


            stream_featuresAdd(i,1:4)=cat(2,stream_pk_fq_4hz,stream_pk_fq,stream_slope_4hz,stream_slope);
            cross_featuresAdd(i,1:4)=cat(2,cross_pk_fq_4hz,cross_pk_fq,cross_slope_4hz,cross_slope);
            
            namesAdd={'pk_fq_4hz','pk_fq','slope_4hz','slope'};
              %disp(featuresAdd(i,:))
            %pause; close all

        end

    end

if 1==1
    %features_out=cat(2,features22,featuresAdd);
    
    names_out=cat(2, strcat(name_in,'_stream_',names22), strcat(name_in,'_stream_',namesAdd), ...
                     strcat(name_in,'_cross_',names22) , strcat(name_in,'_cross_',namesAdd) );
    
    features_out=cat(2,stream_features22,stream_featuresAdd,cross_features22,cross_featuresAdd);
  
    table_out=cell2table(num2cell(features_out),'VariableNames',names_out);

end


end

