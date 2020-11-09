# This script plots the relationship between tree fundamental frequency and tree size, 
# tree type and material properties.

# Run a linear model including all potential factors (H, DBH, H2/DBH, H/DBH, WD) 
# For the whole data set and for different groupings. Optmize by AIC and p-value 
# Report the best models.

library(dplyr); library(tidyr); library(readxl); library(olsrr); library(broom)
library(ggplot2); library(RColorBrewer); library(hexbin); library(clipr)

TT <- read_excel("C:/Users/tobyd/Documents/Data/TreeMotion_Data/OrganizedData/NaturalFrequencies_FieldData_TreeMotionVersion.xlsx",
                    sheet = "Combined_f0_data", na = "NaN")


TT$Type=as.factor(interaction(TT$Clade2,TT$Environment))
TT$Source=as.factor(TT$Source)
TT1=TT[,c("f0","H_m","DBH_m","Type","Clade","Environment","Source","Owner")] 
TT2=na.omit(TT1)
TT2$H2dbh=TT2$H_m**2/TT2$DBH_m
TT2$sqrt1_h=sqrt(TT2$H_m)

path="C:/Users/tobyd/OneDrive - University Of Cambridge/Project Pictures/TreeMotion_Figures/TreeSizeTrends/"
ggplot(TT2,aes(H_m,f0,color=Type,shape=Source))+geom_point(alpha=0.5)+#+facet_wrap(facets=vars(Type))#+scale_shape_manual(values = 3)
  scale_shape_manual(values = c(1, 16))+
  scale_color_manual(values=c(brewer.pal(3,"Set2")[c(1,3,2)],brewer.pal(8,"Set1")[6]))+
  labs(color="Group")+xlab("Tree height (m)")+ylab("Fundamental frequency (Hz)")
ggsave(paste0(path,'f0_vs_H_small_points.png'),width=6,height=4)

ggplot(TT2,aes(sqrt1_h,f0,color=Type,shape=Source))+geom_point(alpha=0.5)+#+facet_wrap(facets=vars(Type))#+scale_shape_manual(values = 3)
  scale_shape_manual(values = c(1, 16))+
  scale_color_manual(values=c(brewer.pal(3,"Set2")[c(1,3,2)],brewer.pal(8,"Set1")[6]))+
  scale_x_log10()+scale_y_log10()+
  labs(color="Group")+theme(legend.position = "none")+
  xlab(expression(log(H^-0.5)))+ylab(expression(log(f[0])))
ggsave(paste0(path,'f0_vs_pendulum_small_points_loglog.png'),width=3,height=2)

ggplot(TT2,aes(H2dbh,f0,color=Type,shape=Source))+geom_point(alpha=0.5)+#+facet_wrap(facets=vars(Type))#+scale_shape_manual(values = 3)
  scale_color_manual(values=c(brewer.pal(3,"Set2")[c(1,3,2)],brewer.pal(8,"Set1")[6]))+
  scale_shape_manual(values = c(1, 16))+
  scale_x_log10()+scale_y_log10()+
  labs(color="Group")+theme(legend.position = "none")+
  xlab(expression(log(H^2/dbh)))+ylab(expression(log(f[0])))
ggsave(paste0(path,'f0_vs_cantilever_small_points_loglog.png'),width=3,height=2)


###########################################################
## LINEAR MODELS 
TT3=filter(TT2,Type=="Angio.Forest")

fit1 <- lm(f0~sqrt1_h, TT3)
fit2 <- lm(log(f0)~log(sqrt1_h), TT3)
a=glance(fit1)
b=glance(fit2)
model_summary=c(a$adj.r.squared,a$AIC,b$adj.r.squared,b$AIC)
write_clip(t(model_summary))

plot(fit1)
plot(fit2)

## Need to decide between f0~H and f0~sqrt(1/H) for the Angiosperms
## They are equivalent on a log scale
TT3=filter(TT2,Clade=="Angio")
ggplot(TT3,aes(sqrt1_h,f0))+geom_point(alpha=0.5)+facet_wrap(facets=vars(Type))#+scale_shape_manual(values = 3)
ggplot(TT3,aes(H_m,f0))+geom_point(alpha=0.5)+facet_wrap(facets=vars(Type))#+scale_shape_manual(values = 3)


TT3=filter(TT2,Type=="Angio.Forest") 
fit1 <- lm(f0~H_m, TT3)
plot(fit1)
fit2 <- lm(f0~sqrt1_h, TT3)
plot(fit2)
fit3 <- lm(log(f0)~log(sqrt1_h), TT3)
fit4 <- lm(log(f0)~log(sqrt1_h), TT3)
