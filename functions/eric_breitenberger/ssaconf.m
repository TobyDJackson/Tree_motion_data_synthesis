function [f,g,v]=ssaconf(V,N)
% Calculates various heuristic confidence limits for SSA.
% Syntax: [f,g,v]=ssaconf(V,N);
% Given a singular value vector V and the number of points
% in the original series N, ssaconf returns vectors containing
% the 95% confidence interval. These are calculated according 
% to the variance formulas of:
%     f: Fraedrich 1986
%     g: Ghil and Mo 1991a
%     v: Vautard, Yiou, and Ghil 1992.
% All estimates are for the 95% confidence level.
% These simple estimates may be adequate for some purposes,
% but none of them adequately consider the autocorrelation 
% of the time series. The estimates g and v are very similar
% for N>>M. They are usually fairly conservative, as they
% correspond to a decorrelation time of M. The Fraedrich
% estimate is valid only for uncorrelated data, so it tends  
% to give error estimates which are too small.
%
% Written by Eric Breitenberger, version date 11/3/95.
% Please send comments to eric@gi.alaska.edu

M = length(V);
f = 2*sqrt(2/N)*V;
g = sqrt(2*M/(N-M))*V;
v = 1.96*sqrt(M/(2*N))*V;
