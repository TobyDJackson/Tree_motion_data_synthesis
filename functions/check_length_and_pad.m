function data_out = check_length_and_pad(data_in,expected_len,low_lim,high_lim,replace)
 
% Just a quick function to check whether the data is the expected length,
% and pad it (with nans, means etc) if it is within reasonable limits, or
% throw an error.
    
  len_in=size(data_in,1);
  if len_in==expected_len; %If it is the correct length, just carry on
      data_out=data_in;
  elseif len_in<expected_len && len_in>low_lim; % if it is under, pad it
      disp('data in is too short, padding')
      if replace==1; % with nans
        data_out=cat(1,data_in,nan(expected_len-len_in,size(data_in,2)));
      end
      if replace==2; % with column means
          data_out=cat(1,data_in,mean(data_in,1).*ones(expected_len-len_in,size(data_in,2)));
      end
  elseif len_in>expected_len && len_in<high_lim;% if it is over, downsample
      disp('data in is too long - downsampled')
      data_out=data_in(1:expected_len,:);
  else
      disp(strcat('Error - length of data = ',num2str(len_in),', expecting ',num2str(expected_len)))
      pause
  end
  
end

