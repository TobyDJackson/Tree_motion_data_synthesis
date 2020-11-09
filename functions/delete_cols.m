function [metrics_lesscols] = delete_cols(metrics_in,cols_delete,batch_width,batches)
    temp_delete=cols_delete;
    for i=1:batches-1
        cols_delete=cat(2,cols_delete,temp_delete+i*batch_width);
    end
    metrics_lesscols=metrics_in;
    metrics_lesscols(:,cols_delete)=[];
end

