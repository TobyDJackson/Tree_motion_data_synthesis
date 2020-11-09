  function [R]=rc(A,E)
% Syntax: [R]=rc(A,E);
% This function calculates the 'reconstructed components' using the 
% eigenvectors (E, from ssaeig.m) and principal components (A, from pc.m).
% R is N x M, where M is the embedding dimension used in ssaeig.m.
%
% See section 2.5 of Vautard, Yiou, and Ghil, Physica D 58, 95-126, 1992.
%
%  Written by Eric Breitenberger.   Version date 5/18/95
%  Please send comments and suggestions to eric@gi.alaska.edu   

[M,c]    = size(E);
[ra, ca] = size(A);

if M~=c, error('E is improperly dimensioned.'),end

if ca~=M, error('A is improperly dimensioned.'),end

N = ra+M-1;  % Assumes A has N-M+1 rows.

R = zeros(N,M);
Z = zeros(M-1,M);
A = [A' Z'];
A = A';

% Calculate RCs
for k = 1:M
    
  R(:,k) = filter(E(:,k),M,A(:,k));
  
end

% Adjust first M-1 rows and last M-1 rows
for i = 1:M-1
    
  R(i,:)     = R(i,:)*(M/i);
  R(N-i+1,:) = R(N-i+1,:)*(M/i);
  
end
