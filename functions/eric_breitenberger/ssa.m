function [E,V,A,R,C]=ssa(x,M,method) 
%  SSA - driver routine to perform Singular Spectrum Analysis
%  Syntax: [E,V,A,R,C]=ssa(x,M); [E,V,A,R,C]=ssa(x,M,'BK');
%
% Input:    x - time series
%           M - embedding dimension.
%      method - (optional) method of calculating the covariance matrix:
%                 'unbiased' (N-k weighted) (default)
%                 'biased'   (N-weighted or Yule-Walker)  
%                 'BK'       (Broomhead/King type estimate)
%
% Output: E - eigenfunction (T-EOF) matrix in standard form
%         V - vector containing variances (unnormalized eigenvalues)
%         A - Matrix of principal components
%         R - Matrix of reconstructed components
%         C - Covariance matrix
%
%  See Vautard, Yiou, and Ghil, Physica D 58, 95-126, 1992.
%
%  Written by Eric Breitenberger.     Version date 1/22/96
%  Please send comments and suggestions to eric@gi.alaska.edu   

if nargin==2, method = 'unbiased'; end

[E,V,C] = ssaeig(x,M,method);
[A]     = pc(x,E);
V       = V/sum(V);         %Normierung mit Summe der Varianzen
[R]     = rc(A,E);


