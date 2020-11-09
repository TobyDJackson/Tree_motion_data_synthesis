function  c=ac(x,k,method)
%    Syntax c=ac(x,k);  c=ac(x,k,'biased');  
% AC calculates the auto-covariance for series x out to lag k. The 
% result is output in c, which has k+1 elements. The first element
% is the covariance at lag zero; succeeding elements 2:k+1 are the
% covariances at lags 1 to k.
%
% Method can be: - 'biased'   (N-weighted or Yule-Walker)  
%                - 'unbiased' (N-k weighted - this is the default)
%                - 'BK'       (Broomhead/King type estimate)
%
% Note that the BK method is of limited use unless you are computing
% the full covariance matrix - see BK.M.                    
%
% Written by Eric Breitenberger.   Version date 1/11/96
% Please send comments and suggestions to eric@gi.alaska.edu   
 
[N,col]=size(x);
if col>N, tmp=col; col=N; N=tmp; end
if k>=N, error('Too big a lag!'), end
if col>1, error('Vectors only!'), end

x=x(:);
x=x-mean(x); % center the series.
c=zeros(1,k+1);

if nargin==2, method='unbiased'; end

if strcmp(method, 'unbiased')
  for i=1:k+1
   c(i)=(x(1:N-i+1)'*x(i:N))/(N-i+1);
  end

elseif strcmp(method,'biased')
  for i=1:k+1
    c(i)=x(1:N-i+1)'*x(i:N);
  end
  c=c./N;

elseif strcmp(method,'BK')
  for i=1:k+1
    c(i)=x(1:N-k)'*x(i:N-k+i-1);
  end
  c=c./(N-k);

else
  error('Improper specification of method.')
end

