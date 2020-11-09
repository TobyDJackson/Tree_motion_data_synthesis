function [h,coeff, score, explained] = pca_arrow_plot3(metrics_in1,metrics_in2, metrics_in3,...
    pc_x,pc_y,g,LINES,color_in,Legend,VarLines)

    % The idea is to have arrows from one to another

    [coeff,score,latent,tsquared,explained,mu] = pca(metrics_in1);
    score_proj2=metrics_in2*coeff;
    score_proj3=metrics_in3*coeff;

    categs=grp2idx(g);
    if LINES==1
        for i=1:length(score)
            plot([score(i,1) score_proj2(i,1)], [score(i,2) score_proj2(i,2)],'k')
            hold on
            plot([score_proj2(i,1) score_proj3(i,1)], [score_proj2(i,2) score_proj3(i,2)],'k')
        end
    end
    h=gscatter(score_proj2(:,pc_x),score_proj2(:,pc_y),categs,color_in,'x'); hold on;
    h=gscatter(score_proj3(:,pc_x),score_proj3(:,pc_y),categs,color_in);
    h=gscatter(score(:,pc_x),score(:,pc_y),g,color_in,'s'); hold on;


 
    xlabel(strcat('PC',num2str(pc_x),' (',num2str(round(explained(pc_x),1)), '%)'),'FontSize',12)
    ylabel(strcat('PC',num2str(pc_y),' (',num2str(round(explained(pc_y),1)), '%)'),'FontSize',12)
    xticks ''; yticks ''; 
    set(gca, 'FontName', 'Helvetica','FontSize', 10)
    
    if Legend==0; legend off; end
    
    if VarLines==1
        a=20; fs=9;
        for i=1:length(coeff(:,1))
            hold on
            plot(a*cat(1,0,coeff(i,pc_x)),a*cat(1,0,coeff(i,pc_y)),'k')
            text(a*coeff(i,pc_x)+0.1,a*coeff(i,pc_y),num2str(i),'FontWeight', 'bold','FontSize',fs)
        end
    end
    
end


