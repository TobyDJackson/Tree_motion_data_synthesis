%-------------------------- Begin itc.m ---------------------------------------
function [kaic,kmdl,aic,mdl]=DIRK_itc(V,n);
% Syntax: [kaic,kmdl,aic,mdl]=itc(V,n);
% Compute signal/noise separation using information-theoretic
% criteria. Two estimates are returned: the Akaike 
% information-theoretic criterion (AIC), and the minimum
% description length (MDL). The order for which AIC or MDL is
% minimum gives the number of significant components in the 
% signal. The two methods often give considerably different 
% results: AIC usually performs better than MDL in low SNR
% situations, but MDL is a consistent estimator, and thus 
% performs better in large-sample situations.
%
% See Wax and Kailath, 1985, Trans. IEEE, ASSP-33, 387-392.
%
% Input:   V: an eigenspectrum (sorted in decreasing order)
%          n: the number of samples used to compute V.
% Outputs: kaic: the order for which AIC is minimum;
%          kmdl: the order for which MDL is minimum;
%          aic: vector containing AIC estimates;
%          mdl: vector containing MDL estimates.
%
% Written by Eric Breitenberger, version 10/4/95, please send 
% any comments and suggestions to eric@gi.alaska.edu

p=length(V);
V=V(p:-1:1);

% Calculate log-likelihood function:
L=zeros(1,p);
nrm=p:-1:1;
sumlog=cumsum(log(V));
sumlog=sumlog(p:-1:1);
logsum=log(cumsum(V));
logsum=logsum(p:-1:1);

L=n*nrm.*((sumlog./nrm)-logsum+log(nrm));

% Calculate penalty function:
pen=(0:p-1);
pen=pen.*(2*p-pen);

% Calculate AIC and MDL, and find minima:
aic=-L+pen;
mdl=-L+pen*log(n)/2;
kaic=find(aic==min(aic))-1;
kmdl=find(mdl==min(mdl))-1;
%-------------------------- End itc.m -----------------------------------------