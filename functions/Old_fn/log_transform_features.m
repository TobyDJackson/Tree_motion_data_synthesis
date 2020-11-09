function [features_log] = log_transform_features(features_in,cols_log,batch_width,batches)

    % takes only the real part.
    % pretty clunky but it works
    %% log non-normal features
    features_log=features_in;
    if 1==2
        features_log(:,cols_log)=log(features_in(:,cols_log));
        features_log(:,cols_log+batch_width)=log(features_in(:,cols_log+batch_width));
        features_log(:,cols_log+2*batch_width)=log(features_in(:,cols_log+2*batch_width));
        features_log(:,cols_log+3*batch_width)=log(features_in(:,cols_log+3*batch_width));
    end
    if 1==1
        features_log(:,cols_log)=log(features_in(:,cols_log));
        if batches>=2
            features_log(:,cols_log+batch_width)=log(features_in(:,cols_log+batch_width));
        end
        if batches>=3
            features_log(:,cols_log+2*batch_width)=log(features_in(:,cols_log+2*batch_width));
        end
        if batches>=4
            features_log(:,cols_log+3*batch_width)=log(features_in(:,cols_log+3*batch_width));
        end
        if batches>=5
            features_log(:,cols_log+4*batch_width)=log(features_in(:,cols_log+4*batch_width));
        end
        if batches>=6
            features_log(:,cols_log+5*batch_width)=log(features_in(:,cols_log+5*batch_width));
        end
        if batches>=7
            features_log(:,cols_log+6*batch_width)=log(features_in(:,cols_log+6*batch_width));
        end
        if batches>=8
            features_log(:,cols_log+7*batch_width)=log(features_in(:,cols_log+7*batch_width));
        end
    end

    features_log=real(features_log);
    [rowInf,colInf]=find(isinf(features_log)==1); %The log function creates some inf, so I replace with nan
    features_log(rowInf,colInf)=NaN;
end

