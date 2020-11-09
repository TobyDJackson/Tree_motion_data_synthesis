function [metrics_ztrans] = ztrans_metrics(metrics_in,MODE)

    PLOT=0;
  %% z-transform all metrics (centres and scales)
    metrics_ztrans=nan(size(metrics_in));
       
    if MODE==1
        for col=1:size(metrics_in,2)
            %col
            a=metrics_in(:,col);
            a_std=std(a,'omitnan');
            a_mean=mean(a,'omitnan');
            metrics_ztrans(:,col)=(a-a_mean)/a_std; 

            if PLOT==1
                subplot(1,2,1)
                hist(metrics_in(:,col))
                %title(names{col})
                subplot(1,2,2)
                hist(metrics_ztrans(:,col))
                pause
            end
        end
    end % end of MODE==1
    
    if MODE==2
    end
    metrics_ztrans=real(metrics_ztrans);
end

