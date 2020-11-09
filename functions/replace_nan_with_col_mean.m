function array_out = replace_nan_with_col_mean(array_in)
% This function loops over the columns in a 2D array and replaces the nans
% with the mean of the column
for i=1:size(array_in,2);
    %temp=array_in(:,i);
    array_in(isnan(array_in(:,i)),i)=mean(array_in(:,i),'omitnan');
    %array_out=
end
array_out=array_in;
end

