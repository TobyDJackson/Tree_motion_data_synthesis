
# This script was used to do all the feature analysis for the Tree Motion paper
# The data it uses are summary data contained in the TreeTable
# Each row is a tree (N=238). 
# The first 35 columns are tree attributes, the 54 subsequent columns are features of tree motion

# This script does:

# Basics
# 1. Sort & scale data
# 2. PCA

# Classification
# 3. Supervised clustering - LDA (Linear discriminant analysis)
# 4. Classification - LDA
# 5. Multinomial regression - find most explanatory features

# Tree size trends
# 6. Tree size trends
# 7. Individual features vs tree size


#This chunk loads the packages and colours
library(dplyr);   library(tidyr);     library(magrittr);  library(broom)
library(readxl); library(clipr);     library(matrixStats); 
library(ggplot2); library(RColorBrewer); library(corrplot);  library(factoextra); 
library(rcompanion); # for Tukey transformation
library(MASS); # for lda
library(caret); # for cross-validation
library(olsrr);    


setwd("C:/Users/tobyd/OneDrive - University Of Cambridge/R/TreeMotion_RProject")
TreeMotion_Figures="C:/Users/tobyd/OneDrive - University Of Cambridge/Project Pictures/TreeMotion_Figures/"

# Selections of rows - trees
# All trees (238)
# Even samples - 63 of each
# Main groups - Angio.Forest, Angio.Open, Gymno.Forest


################################################################
# 1 - Sort data
#This chunk imports the data
TT = read_excel("C:/Users/tobyd/OneDrive - University Of Cambridge/Papers/Papers - in progress/TreeMotion/Tables/Tree table - supplementary.xlsx", na = "NaN")
TT=as.data.frame(TT) 
TT$Sensor=as.factor(TT$Sensor)
TT$Type=interaction(TT$Clade2,TT$Environment)
is.na(TT) = sapply(TT, is.infinite) #replaces inf with na
feature_cols=grep("sh_", colnames(TT))

# LEFT SKEWED 
#left_skewed=c("sh_s_f0_h","sh_s_MD_hrv_classic_pnn40","sh_s_SP_Summaries_welch_rect_area_5_1","sh_c_MD_hrv_classic_pnn40","sh_c_SP_Summaries_welch_rect_area_5_1")
TT[,feature_cols[c(5,17,26,39,48)]]=1-TT[,feature_cols[c(5,17,26,39,48)]]
column.names=colnames(TT) 
TT_scaled=TT[rowSums(is.na(TT[,feature_cols]))==0,] #delete rows with remaining NAs
TT_scaled[,feature_cols]=scale(TT_scaled[,feature_cols])

# Look at distribution of features 
i=17
column.names[feature_cols[i]]
hist(TT[,c(feature_cols[i])])
hist(log(TT[,c(feature_cols[i])]))
hist(transformTukey(TT[,c(feature_cols[i])]))

# Log tranformation of the most skewed features (hand-selected)
TT_log=TT
logCols=c(2,4,5,13,14,16:21,23,26,27,31,35,36,38:43,45,48,49,53) #
TT_log[,feature_cols[logCols]]=log(TT_log[,feature_cols[logCols]]+100)# Add offset and log-transform
is.na(TT_log) = sapply(TT_log, is.infinite) #replaces inf with na
TT_log[,feature_cols]=scale(TT_log[,feature_cols])
# remove cols with too many NAs
plot(colSums(is.na(TT_log[feature_cols])))
TT_log=TT_log[rowSums(is.na(TT_log[,feature_cols]))==0,] #delete rows with remaining NAs


a=TT_log[,feature_cols]
lit=feature_cols[c(1:10)]
c22_all=feature_cols[c(11:54)]
c22_stream=feature_cols[c(11:32)]
lit_c22_stream=c(lit,c22_stream)
lit_c22=c(lit,c22_all)

#Correlation / covariance plots 
corrplot::corrplot(cor(TT_scaled[,lit_c22_stream]),type='lower' ,tl.pos='n',tl.cex=0.7) #tl.pos='n' or 'l'
corrplot::corrplot(cor(TT_scaled[,lit_c22_stream]),type='lower' ,tl.pos='l',tl.cex=0.7,tl.col='black')
corrplot::corrplot(as.matrix(corrs),type='lower' ,tl.pos='l',tl.offset=0.2,tl.cex=1,tl.col='black',cl.length=5,cl.cex=1) #tl.pos='n' or 'l'


################################################################
# 2a - PCA analysis

TT_pca=TT_scaled
pca.full = prcomp(TT_pca[,lit_c22_stream], center = TRUE,scale. = TRUE)
TT_pca$PC1=pca.full$x[,1]; TT_pca$PC2=pca.full$x[,2]
eigs   =pca.full$sdev^2
PC1.explained=100*eigs[1]/sum(eigs); PC2.explained=100*eigs[2]/sum(eigs)

# Plot PCA with ellipses around three main groups only
ggplot(data=filter(TT_pca,Type !="Conifer.Open"),
       aes(PC1,PC2,color=Type))+stat_ellipse()+ 
  geom_jitter(data=TT_pca,aes(color=Type,shape=Sensor))+
  xlab(paste0("PC1 ",round(PC1.explained),"%"))+
  ylab(paste0("PC2 ",round(PC2.explained),"%"))+
  labs(color = "Group",shape="Sensor")+
  scale_color_manual(values=c(brewer.pal(3,"Set2")[c(1,3,2)],brewer.pal(8,"Set1")[6]))+
  scale_x_reverse() # so that it is similar to the LDA

theme(axis.text.x=element_blank(),axis.ticks.x=element_blank(),
      axis.text.y=element_blank(),axis.ticks.y=element_blank()) 
  
#setwd(paste0(TreeMotion_Figures))
ggsave("PCA_TT_scaled_224_Type_Sensor_StreamwiseOnly.png",height=3,width=5)

# Contributions of variables to PCs
fviz_contrib(pca.full, choice = "var", axes = 1, top = 5)
fviz_contrib(pca.full, choice = "var", axes = 2, top = 5)
#ggsave(plot=p,'Contributions.png',height=6,width=10)


# 2b - PCA analysis from weighted sample
# Calculate PCA from representative sample and then project
# This doesn't make much of a difference so I'm sticking with the above
# Variance explained in the following is only for the subset
summary(TT_pca$Type)
TT_even_sample= bind_rows(filter(TT_pca,Type %in% "Angio.Open"),
                          TT_pca %>% filter(Type=="Angio.Forest") %>% sample_n(size=63,replace=FALSE),
                          TT_pca %>% filter(Type=="Gymno.Forest") %>% sample_n(size=63,replace=FALSE))

pca.even_sample = prcomp(TT_even_sample[,lit_c22_stream], center = TRUE,scale. = TRUE)
TT_even_sample$PC1=pca.even_sample$x[,1]; TT_even_sample$PC2=pca.even_sample$x[,2]
eigs = pca.even_sample$sdev^2; 
PC1.explained=100*eigs[1]/sum(eigs); PC2.explained=100*eigs[2]/sum(eigs)
ggplot(data=TT_even_sample,aes(PC1,PC2,color=Type,shape=Sensor))+geom_point()+
  xlab(paste0("PC1 ",round(PC1.explained),"%"))+ylab(paste0("PC2 ",round(PC2.explained),"%"))+
  theme(axis.text.x=element_blank(),  axis.ticks.x=element_blank(),axis.text.y=element_blank(),axis.ticks.y=element_blank())+
  scale_color_manual(values=c(brewer.pal(3,"Set2")[c(1,3,2)],brewer.pal(8,"Set1")[6]))


################################################################
# 3 - LDA for clustering
#Do the LDA on the whole data set (it will overfit) and find the most useful 

lit=feature_cols[c(1:10)]
c22_all=feature_cols[c(11:54)]
c22_stream=feature_cols[c(11:32)]
lit_c22_stream=c(lit,c22_stream)
lit_c22=c(lit,c22_all)


TT_lda=TT_scaled %>% dplyr::select(Type,all_of(lit_c22_stream)) %>% 
  filter(Type!="Conifer.Open") %>% group_by(Type)

for (i in c(1:10)){
  TT_even_sample= bind_rows(filter(TT_lda,Type %in% "Broadleaf.Open"),
                            TT_lda %>% filter(Type=="Broadleaf.Forest") %>% sample_n(size=63,replace=FALSE),
                            TT_lda %>% filter(Type=="Conifer.Forest") %>% sample_n(size=63,replace=FALSE))
  #TT_even_sample=TT_lda
  lda_result= lda(Type ~ .,TT_even_sample) # LDA using all features
  prop.lda = lda_result$svd^2/sum(lda_result$svd^2)
  
  # get importance of each feature in each LD axis
  lda_result.s=100*abs(lda_result$scaling)/(sum(abs(lda_result$scaling)))
  lda_feature_weight=data.frame(names=colnames(TT_even_sample)[2:ncol(TT_even_sample)],LD1=lda_result.s[,1],LD2=lda_result.s[,2])
  
  print(lda_feature_weight[order(-lda_feature_weight$LD1),][c(1),])# order the feature contributions by importance
  print(lda_feature_weight[order(-lda_feature_weight$LD2),][c(1),])# order the feature contributions by importance
  #writeClipboard(as.character(b))
}

# Essentially I got the most explanatory variables and plotted them out. 
ggplot(data=TT,aes(sh_s_slope_005_2,sh_s_FC_LocalSimple_mean3_stderr,shape=Sensor,color=Type))+geom_point()+
  theme(axis.text.x=element_blank(),  axis.ticks.x=element_blank(),axis.text.y=element_blank(),axis.ticks.y=element_blank())+
  scale_color_manual(values=c(brewer.pal(3,"Set2")[c(1,3,2)],brewer.pal(8,"Set1")[6]))

#ggsave("LDA_sh_s_slope_0005_2_sh_s_FC_LocalSimple_mean3_stderr.png",height=3,width=5)

ggplot(data=TT2,aes(PC1,PC2,color=Type,shape=Sensor))+geom_point()+xlab(paste0("PC1 ",round(PC1.explained),"%"))+ylab(paste0("PC2 ",round(PC2.explained),"%"))+
  theme(axis.text.x=element_blank(),  axis.ticks.x=element_blank(),axis.text.y=element_blank(),axis.ticks.y=element_blank())


# Plot in the original scale
TT_not_scaled_short=filter(TT,Type %in% c("Broadleaf.Forest","Broadleaf.Open","Conifer.Forest"))

ggplot(data=TT_not_scaled_short,aes(sh_s_FC_LocalSimple_mean3_stderr,sh_s_slope_005_2,color=Type))+stat_ellipse()+
  geom_jitter(data=TT,aes(color=Type,shape=Sensor))+ylim(-5,1)+
  ylab("Power spectrum slope")+xlab("Mean error from 1s forecast")+
  labs(color = "Group",shape="Sensor")+
  scale_color_manual(values=c(brewer.pal(3,"Set2")[c(1,3,2)],brewer.pal(8,"Set1")[6]))

ggsave("LDA_sh_s_slope_0005_2_sh_s_FC_LocalSimple_mean3_stderr_relabeled.png",height=3,width=5)




#########################################################
# 4 - Classification using Random forests - 
lit=feature_cols[c(1:10)]
c22_all=feature_cols[c(11:54)]
c22_stream=feature_cols[c(11:32)]
lit_c22_stream=c(lit,c22_stream)
lit_c22=c(lit,c22_all)

TT_classify=TT_scaled %>% # Select the (transformed) data
  dplyr::select(Type,all_of(lit_c22_stream)) %>% # select the features to use
  filter(Type!="Conifer.Open") %>% group_by(Type) # Get rid of the 12 Gymno.Opens

TT_classify$Type=droplevels(TT_classify)$Type # Drop the empty group - otherwise R remembers 

# Sample 63 of each group, then 50:50 test/train split, train, test - repeat X 50 
confusion_matrices = lapply(rep(0.5,50), function(x){
  # Randomly sample 63 of each group
  TT_even_sample= bind_rows( TT_classify %>% filter(Type=="Broadleaf.Forest") %>% sample_n(size=63,replace=FALSE),
                             TT_classify %>% filter(Type=="Conifer.Forest") %>% sample_n(size=63,replace=FALSE))#,
  #filter(TT_classify,Type %in% "Broadleaf.Open"),
  # Split data into training / testing
  TT_even_sample$Type=droplevels(TT_even_sample)$Type # Drop the empty group - otherwise R remembers 
  
  index = createDataPartition(TT_even_sample$Type, p = 0.5,list=FALSE) 
  train = TT_even_sample[index, ]
  test = TT_even_sample[-index, ]
  # Build model
  rf_classifier=randomForest(Type ~ ., data=train, ntree=10, mtry=5, importance=TRUE)
  # Predict classes
  rf_prediction <- predict(rf_classifier,test)
  # Assess model
  conf=confusionMatrix(as.factor(rf_prediction),test$Type)
  return(conf$table)
})

confusion_Mean = Reduce('+', confusion_matrices) / 50
confusion_Mean
kappa(confusion_Mean)


#varImpPlot(rf_classifier)
write.table(confusion_Mean, "clipboard", sep="\t", row.names=FALSE,col.names = FALSE)
write.table(confusion_Mean, "clipboard", sep="\t")
#######################################




####################################################################
## 5 - Multi-nomial regression 

TT_mlr=TT_scaled %>% dplyr::select(Type,all_of(lit_c22_all)) %>% 
  filter(Type!="Gymno.Open")

TT_mlr$Type=droplevels(TT_mlr)$Type # Drop the empty group - otherwise R complains


# Predict  (mlr) tree type with each feature individually
# Also get correlation between each feature and the best predictor - slope_0.005_2
mlr_results=data.frame(index=seq(1,ncol(TT_mlr)),Feature=colnames(TT_mlr),
                       Gymno.Forest=rep(NA,ncol(TT_mlr)),Angio.Open=rep(NA,ncol(TT_mlr)),
                       Correlation_with_Swelch=rep(NA,ncol(TT_mlr)))
for (i in c(2:ncol(TT_mlr))){
  mlr_model = nnet::multinom(Type ~ TT_mlr[,i],TT_mlr) 
  temp = t(summary(mlr_model)$coefficients/summary(mlr_model)$standard.errors)
  mlr_results$Gymno.Forest[i]=abs(temp[2,1])
  mlr_results$Angio.Open[i]=abs(temp[2,2])
  lm_model=lm(TT_mlr$sh_s_slope_005_2~TT_mlr[,i])
  mlr_results$Correlation_with_Swelch[i]=summary(lm_model)$r.squared
}
mlr_results$Tree_type_classification=abs(mlr_results$Gymno.Forest)+abs(mlr_results$Angio.Open)
ggplot(mlr_results,aes(x=Tree_type_classification,y=Correlation_with_Swelch))+geom_text(aes(label=mlr_results$index),hjust=0, vjust=0)
mlr_results$Feature[33]

#mlr_results=arrange(mlr_results,desc(Tree_type_classification))
# Look at residuals and test with data that hasn't been log transformed

##################################################################




####################################################################
# 6 - Tree size trends - should I do this for each group individually?
 #  Linear modelling of tree size against motion features - based on
# https://cran.r-project.org/web/packages/olsrr/vignettes/variable_selection.html


pca.full = prcomp(TT_log[,lit_c22_stream], center = TRUE,scale. = TRUE)
TT_log$PC1=pca.full$x[,1]; TT_log$PC2=pca.full$x[,2]

TT_size_trends=TT_scaled %>% filter(!Type=="Gymno.Open",!is.na(H_m),!is.na(DBH_m)) 
summary(TT_size_trends$Type)

# Test correlation between tree size and PCs - 
# Result = low. dbh~PC2 R2=0.17, all others R2<0.05
lm1=lm(DBH_m~PC2,data=TT_size_trends)
summary(lm1)
ggplot(TT_size_trends, aes(x = PC2, y = DBH_m))+geom_point()

# Test predictability of tree size from tree motion
TT_size_trends_select= TT_size_trends %>%  
  dplyr::select(H_m,Type,all_of(lit_c22_stream))
lm1=lm(H_m~.,data=TT_size_trends_select)
summary(lm1)
lm2=ols_step_both_aic(lm1)
summary(lm2)
a=data.frame(predictors=lm2[["predictors"]],method=lm2[["method"]],R2Adj=lm2[["arsq"]],AIC=lm2[["aic"]])
print(a)
clipr::write_clip(a)

plot(lm2)
#sh_s_IN_AutoMutualInfoStats_40_gaussian_fmmi
#sh_s_CO_FirstMin_ac
#sh_s_SB_MotifThree_quantile_hh
#sh_s_FC_LocalSimple_mean3_stderr
lm3=lm(DBH_m~sh_s_FC_LocalSimple_mean3_stderr,data=TT_size_trends)
summary(lm3)
#lm3=lm(DBH_m~Type,data=TT_size_trends)
plot(lm3)
  
####################################################################
# 7 - Individual feature correlation and covariance with tree height / dbh

lit=feature_cols[c(1:10)]
c22_all=feature_cols[c(11:54)]
c22_stream=feature_cols[c(11:32)]
lit_c22_stream=c(lit,c22_stream)
lit_c22=c(lit,c22_all)

TreeMotion_Figures="C:/Users/tobyd/OneDrive - University Of Cambridge/Project Pictures/TreeMotion_Figures/"

TT_size_trends_select= TT_size_trends %>%  
  dplyr::select(H_m,DBH_m,all_of(lit_c22_stream))

corrs=as.data.frame(cor(TT_size_trends_select)) %>% filter(abs(H_m)>0.3 | abs(DBH_m)>0.3)

corrplot::corrplot(as.matrix(corrs),type='lower' ,tl.pos='l',tl.offset=0.2,tl.cex=1,tl.col='black',cl.length=5,cl.cex=1) #tl.pos='n' or 'l'
#ggsave(plot=p,paste0(TreeMotion_Figures,'Feature_Clustering/Corrplot_169_H_dbh_lit_c22_stream.png'),height=8,width=8)
  

TT_size_trends=TT_log %>% 
  filter(!Type=="Gymno.Open",!is.na(H_m),!is.na(DBH_m)) %>%  
  dplyr::select(H_m,Type,all_of(lit_c22_stream))

## Loop over each variable and predict tree size
lm_results=data.frame(index=seq(1,ncol(TT_size_trends)),Feature=colnames(TT_size_trends),
                       Corr_without_type=rep(NA,ncol(TT_size_trends)),
                       Corr_with_type=rep(NA,ncol(TT_size_trends)),
                       Corr_with_type_and_feature1=rep(NA,ncol(TT_size_trends)))

for (i in c(3:ncol(TT_size_trends))){
  # Without tree type
  lm1=tidy(lm(H_m~TT_size_trends[,i],TT_size_trends))
  lm_results$Corr_without_type[i]=abs(lm1$estimate[2]/lm1$std.error[2])
  # With tree type
  lm2=tidy(lm(H_m~TT_size_trends$Type +TT_size_trends[,i],TT_size_trends))
  lm_results$Corr_with_type[i]=abs(lm2$estimate[4]/lm2$std.error[4])
  # With tree type and 1st predictor
  #lm_model=lm(TT_size_trends$sh_s_slope_005_2~TT_size_trends[,i])
  #mlr_results$Correlation_with_Swelch[i]=summary(lm_model)$r.squared
  lm3=tidy(lm(H_m~TT_size_trends$Type +TT_size_trends[,23]+TT_size_trends[,i],TT_size_trends))
  lm_results$Corr_with_type_and_feature1[i]=abs(lm3$estimate[5]/lm3$std.error[5])
}
#mlr_results$Tree_type_classification=abs(mlr_results$Gymno.Forest)+abs(mlr_results$Angio.Open)
ggplot(lm_results,aes(x=Corr_with_type,y=Corr_with_type_and_feature1))+geom_text(aes(label=lm_results$index),hjust=0, vjust=0)
lm_results$Feature[23]
# H is 23 and 11
