function [z] = binned_log_means(x,y,n,min_x)
    %This function takes the mean of each bin of y accordinging to
    %logarithmically binned x values.  

       bin_vec = logspace(log10(min_x),log10(max(x)),n);
       z=nan(n-1,2);
       for i=1:n-1
           temp_rows=find(x>=bin_vec(i) & x<bin_vec(i+1));
           z(i,1:2)=[mean(x(temp_rows)), mean(y(temp_rows))];
       end
end

