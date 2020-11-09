  function [C]=bk(X, M)
%  Syntax: C=bk(X, M); 
%  BK computes a Broomhead/King type covariance matrix for the
%  centered multichannel process X, for embedding dimension 'M'.
%  Each of the columns of X is a time series.
%
%  Note that X must be centered.
%
%  Returns:   C - lag-covariance matrix.
%
%  Written by Eric Breitenberger.    Version date 1/11/96
%  Please send comments and suggestions to eric@gi.alaska.edu   
%
[N,L]=size(X);
if M*L>=N-M+1, disp('Warning: Covariance matrix may be ill-conditioned.'), end

% Create the trajectory matrix: this code differs from 
% that in EEOF only in the column ordering.
T=zeros(N-M+1,M*L);
index=0:M:(L-1)*M;

for i=1:M
  T(:,index+i)=X(i:N-M+i,:);
end

C=(T'*T)./(N-M+1);



