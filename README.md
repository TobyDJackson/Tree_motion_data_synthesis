# TreeMotion_data
Meta data and code for analyzing tree motion data.

This repo should allow you to reproduce the analysis and figures in the Tree Motion paper (I'll upload the link once its published). 

Data samples stored in 'Data_1hr_samples/' as csv files. All of this data is at 4Hz and there are two columns, corresponding to the two horizontal axes of motion. The name of each file describes the tree and corresponds to a row in the 'Tree table.xls', which provides meta data. These data samples were collected during high wind speed conditions in summer. They were used to extract features using the matlab script HML_features.m (you will need some of the matlab functions in the functions folder and to install catch22 for this step). 

The features are stored in the Tree table, so this can be used directly for statistical analysis using the R script TreeMotion_Features_Sept2020.R. This will reproduce Figure 2 in the paper. 

The data on fundamental frequencies of trees used in Figure 1 is stored in 'NaturalFrequencies_FieldData.xls' and the figure and linear models can be reproduced using the R script fundamental_frequency_models.R. 

There are a lot of other little tools in Matlab to manipulate these data. The full data set is stored at (LINK). 

