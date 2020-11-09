function [table_out] = ...
    calculate_features_fn4(dataPath,TT_in,good_rows,name_in)


    % This one combines the two channels into a single signal and
    % calculates the features on that
    % 
    n=height(TT_in); 
    stream_features22=nan(n,22); cross_features22=nan(n,22);
    stream_featuresAdd=nan(n,2); cross_featuresAdd=nan(n,2);
    ellipticalness=nan(n,1);
    
    SAVE_PROJECTED_4HZ=0;

    % Loop over the files and calculate features
    for j = 1:length(good_rows)
        i=good_rows(j)
        %i
        disp(strcat('i = ' ,num2str(j), ' / ',num2str(length(good_rows))))
        %[author]_[site]_[tree]_[res]_[sensor]_[duration]_[condition]_[wind]
        filename=char(TT_in.Filename(i));
        underscores=strfind(filename,'_');
        %new_filename=strcat(filename(1:underscores(5)),duration,filename(underscores(5)+4:end));
        new_filename=filename(1:underscores(5));
        this_file=dir(strcat(dataPath,'\',new_filename,'*'))
        disp(this_file.name)
        if length(this_file)~=1;  % if the file isn't found
            disp('cant find file'); pause; continue; 
        else
            % Import the data & check length
            data = importfile_SpectralAnalysis(strcat(dataPath,'\',this_file.name));
            data(isnan(data(:,1))==1,:)=[];
            data(isnan(data(:,2))==1,:)=[];
            disp(length(data)./(TT_in.Res_Hz(i)*60*60))
            
            if 1==1 % HighPass filter       
                Nyf = 0.5 * TT_in.Res_Hz(i); % Nyquist-frequency (Hz)    
                lower_frequency_threshold=0.0017; % this is ten minutes
                fOrder        = 4;  
                [b2,a2]       = butter(fOrder,lower_frequency_threshold / Nyf,'high');
                data_test = filtfilt(b2,a2,data);
                %subplot(2,2,1); plot(data(:,1))
                %subplot(2,2,2); plot(data(:,2))
                %subplot(2,2,3); plot(data_test(:,1))
                %subplot(2,2,4); plot(data_test(:,2))  
                %pause; close all
                data=data_test;
                
            end
            
            % Re-project and resample
            [coeff,score,latent,tsquared,explained,mu] = pca(data);
            if 1==2
                biplot(coeff); hold on; 
                plot(data(:,1),data(:,2),'.')
                pause; close all
            end
            ellipticalness(i)=explained(1)/explained(2);
            data_projected=sqrt(data(:,1).^2+data(:,2).^2);
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
        %temp_features2 = catch22_all(data_4hz_projected(:,2));
        %cross_features22(i,1:22)=temp_features2';

        if 1==1 % may need a 'try' function

            % Extract peaks using wavelet transform
            stream_pk_fq_4hz = find_wavelet_peaks2( data_4hz_projected(:,1),4,0.01,50,2); %figure
            %subplot(1,2,1)
            %stream_pk_fq     = find_wavelet_peaks( data_projected(:,1),TT_in.Res_Hz(i),0.01,50,0);
            %cross_pk_fq_4hz = find_wavelet_peaks( data_4hz_projected(:,2),4,0.01,50,0);
            %cross_pk_fq     = find_wavelet_peaks( data_projected(:,2),TT_in.Res_Hz(i),0.01,50,0);
            %pause; close all

            % Calculate slope of the spectrum
            stream_slope_4hz = slope_of_spectrum2(data_4hz_projected(:,1),4,0.05,0.8,'off',2);
            %subplot(1,2,2)
            %stream_slope     = slope_of_spectrum(data_projected(:,1),TT_in.Res_Hz(i),0.05,0.8,'off',0);
            %cross_slope_4hz = slope_of_spectrum(data_4hz_projected(:,2),4,0.05,0.8,'off',0);
            %cross_slope     = slope_of_spectrum(data_projected(:,2),TT_in.Res_Hz(i),0.05,0.8,'off',0);


            stream_featuresAdd(i,1:2)=cat(2,stream_pk_fq_4hz,stream_slope_4hz);
            %cross_featuresAdd(i,1:2)=cat(2,cross_pk_fq_4hz,cross_slope_4hz);
            
            namesAdd={'pk_fq','slope'};
              %disp(featuresAdd(i,:))
            %pause; close all

        end

    end

if 1==1
    %features_out=cat(2,features22,featuresAdd);
    
    names_out=cat(2, strcat(name_in,'_ellipticalness'),...
            strcat(name_in,'_s_',names22), strcat(name_in,'_s_',namesAdd));
            
    
    features_out=cat(2,ellipticalness,stream_features22,stream_featuresAdd);
  
    table_out=cell2table(num2cell(features_out),'VariableNames',names_out);

end


end

