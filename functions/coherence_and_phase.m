%% Coherence and phase
% Output parameters: co-spectrum, coherence, co-coherence (which is coherence with a sign, such that it varies between -1 and 1),
% phase and frequency

% Inputs are vectors or matrices X and Y, freq is a scalar and N is a positive number >
% 1. 

% The time dimension of X and Y should correspond to the rows, such that
% ten minute of data sampled at 20Hz should have the dimension size(X,1) =
% 12000. 

% If X and Y are vectors, the value of N is used to split the time series into equally large
% chunks. For example, if you only have one hour long time series per
% tree, then you can split it into 6 ten minute periods, by
% setting N = 6. 

% If you have several hours or ten minute periods of data, these should be organized
% in a matrix. Then you set N = 1, becuase you already have the necessary
% realizations of the data. 


% ... hope it makes sense. 
function [co, coh, cocoh, phase,f] =  coherence_and_phase(X,Y,freq,N)
xscale = (1:length(X))';      % There might be a bug here (rows 22-30), but it worked in my examples.  In case you have troubles, let me know. Now that I look at it, I think it only works if X and Y are vectors with Nan values. If you have nans and X and Y are matrices, one should loop over the columns.
I = isnan(X);
J = isnan(Y);
if length(find(I)) > 0
    X = interp1(xscale(~I),X(~I),xscale);
end
if length(find(J)) > 0
    Y = interp1(xscale(~J),Y(~J),xscale);
end

if N > 1
    Y = reshape(Y,floor(length(Y)/N),N);  
    X = reshape(X,floor(length(X)/N),N);
end


fftX = fft(X,[],1);
fftY = fft(Y,[],1);

n = length(fftX(:,1));

co = nanmean(real(conj(fftX).*fftY),2);
qu = nanmean(imag(conj(fftX).*fftY),2);
Sx = nanmean(conj(fftX).*fftX,2);
Sy = nanmean(conj(fftY).*fftY,2);

co(1)      = 0; qu(1) = 0;  Sx(1) = 0; Sy(1) = 0;                        % Remove mean contribution
nf         = n/2;                                                       % Nyqvist frequency   
co         = co(1:nf+1);                          
qu         = qu(1:nf+1); 
Sx         = Sx(1:nf+1);
Sy         = Sy(1:nf+1);
co         = co/(freq*n);
qu         = qu/(freq*n);
Sx         = Sx/(freq*n);
Sy         = Sy/(freq*n);
f          = [0:n/2]*freq/n;
f          = f';

coh =(co.^2+qu.^2)./(Sx.*Sy);
cocoh = real(co)./sqrt(Sx.*Sy);
phase = atan2(qu,co); %%% 
sprintf('there might be a 90 deg error in the phase') % This comment was added to remind myself of not trusting the phase completely. You probably won't need it, 