function [data_out] = replace_nan_with_mean(data_in)

    data_out=data_in;    
    
    % replace nans with previous values
    for col=1:size(data_in,2);
        rownan=find( isnan(data_in(:,col))==1 );
        data_out(rownan,col)=mean(data_in(:,col),'omitnan');
    end

end

