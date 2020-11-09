  function [E,V,C]=ssaeig(x,M,method)
%  SSAEIG - starts an SSA of series 'x', for embedding dimension 'M'.
%  Syntax: [E,V,C]=ssaeig(x,M); [E,V,C]=ssaeig(x,M,'BK');  
%
% Input:    x - time series
%           M - embedding dimension.
%      method - (optional) method of calculating the covariance matrix:
%                 'unbiased' (N-k weighted) (default)
%                 'biased'   (N-weighted or Yule-Walker)  
%                 'BK'       (Broomhead/King type estimate)
%
% Output:   E - eigenfunction matrix in standard form
%               (columns are the eigenvectors, or T-EOFs)
%           V - vector containing variances (unnormalized eigenvalues)
%           C - covariance matrix
%
%  E and V are ordered from large to small.
%  See section 2 of Vautard, Yiou, and Ghil, Physica D 58, 95-126, 1992.
%
%  Written by Eric Breitenberger.    Version date 1/22/96
%  Please send comments and suggestions to eric@gi.alaska.edu   
%
if nargin==2, method='unbiased'; end

[N,col]=size(x); 

if col>N, x=x'; [N,col]=size(x); end   % change x to column vector if needed

if M>=N-M+1, error('Hey! Too big a lag!'), end

if col>=2, error('Hey! Vectors only!'), end

if ~strcmp(method,'BK')
  c=ac(x, M-1,method);   % calculate autocovariance estimates
  C=toeplitz(c);         % create Toeplitz matrix (trajectory matrix)
else 
  C=bk(x,M);           % Broomhead/King estimate
end

[E,L]=eig(C);          % calculate eigenvectors, values of C
[V,i]=sort(-diag(L));  % create sorted eigenvalue vector
V=-V';   
E=E(:,i);              % sort eigenvector matrix

