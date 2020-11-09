  function [A] = pc(x, E)
%  PC calculates the principal components of the series x from the eigenfunction matrix E (output from SSAEIG)
%  Syntax:  [A] = pc(x, E); 
%  Returns: A (principal components matrix N - M + 1 x M)
%
%  See section 2.4 of Vautard, Yiou, and Ghil, Physica D 58, 95-126, 1992.
%
%  Written by Eric Breitenberger.    Version date 5/20/95
%  Please send comments and suggestions to eric@gi.alaska.edu   
%
[N,col] = size(x);

if min(N,col) > 1, error('x must be a vector.'), end

if col > 1
    x = x';
    N = col;
end     % convert x to column if necessary.

x = x - mean(x);

[M,c] = size(E);                
if M ~= c, error('E is improperly dimensioned'), end
A = zeros(N - M + 1,M);

% This could be rewritten using 'filter', like MPC.
for i = 1:N - M + 1
    
    w      = x(i:i + M - 1);
    A(i,:) = w' * E;
    
end


