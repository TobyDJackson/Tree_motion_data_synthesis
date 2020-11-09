function [E,V,A,R] = SSA_plot(Z,EBD,sample)

    Z_temp = replace_nan_with_col_mean(Z-mean(Z,'omitnan'));   
    [E,V,A,R] = ssa(Z_temp',EBD);
    dark2=brewermap(8,'dark2');
    
    % Scree plot
    subplot(2,1,1)
    plot(V,'-g+');  ylabel('Explained variance'); xlabel('Embedding dimension'); hold on
    %mean_arr = repmat(mean(V),1:length(mean(V)),1);
    %plot(1:length(V),mean_arr,'-k+');
    
    [kaic,kmdl,aic,mdl]=itc(V,length(Z));
    plot(1:length(V),aic,'-k+');
     
    % Time series plot
    subplot(2,1,2)
    hold on; 
    plot(R(sample,1),'color',dark2(1,:)); 
    plot(R(sample,2),'color',dark2(2,:)); 
    plot(R(sample,3),'color',dark2(3,:)); 
    plot(R(sample,4),'color',dark2(4,:));
    legend('R1','R2','R3','R4')
      
end

