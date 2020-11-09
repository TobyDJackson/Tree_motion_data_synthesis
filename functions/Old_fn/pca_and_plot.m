function [h,coeff, score, explained] = pca_and_plot(features_in,pc_x,pc_y,g,color_in,Legend,VarLines)
% Just a quick function to calculate and plot the pca with groupings
    %pc_x=1; pc_y=2;
    
    [coeff,score,latent,tsquared,explained,mu] = pca(features_in);
    Xcentered = score*coeff';

    %g = {TT_SH.Type,TT_SH.Sensor};% I tried to do two groups
 
    h=gscatter(score(:,pc_x),score(:,pc_y),g,color_in,'.',12); hold on
    %h=gscatter(score(:,pc_x),score(:,pc_y),g,color_in,'........******'); hold on
    %  for all authors plot
    if Legend==0; legend off; end
    if Legend==1; legend('Location','southeast'); end
    if Legend==2; legend('Location','south','NumColumns',2); end
    if Legend==3; legend('Location','eastoutside','NumColumns',1); end
    xlabel(strcat('PC',num2str(pc_x),' (',num2str(round(explained(pc_x),1)), '%)'),'FontSize',12)
    ylabel(strcat('PC',num2str(pc_y),' (',num2str(round(explained(pc_y),1)), '%)'),'FontSize',12)
    %xticks ''; yticks ''; 
    set(gca, 'FontName', 'Helvetica','FontSize', 10)
    
    labels=[1:9 11:26];
    if VarLines==1
        a=20; fs=9;
        for i=1:23%length(coeff(:,1))
            hold on
            plot(a*cat(1,0,coeff(i,pc_x)),a*cat(1,0,coeff(i,pc_y)),'k')
            text(a*coeff(i,pc_x)+0.1,a*coeff(i,pc_y),num2str(labels(i)),'FontWeight', 'bold','FontSize',fs)
        end
    end
end

