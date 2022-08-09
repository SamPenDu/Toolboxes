function C = conv_avg(X,H)
%
% C = conv_avg(X,H)
%
% Returns time series X convolved with hemodynamic response function H.
% The end of C is truncated so that it is the same length as X.
%

nx = length(X); % Length of time series
nh = length(H); % Length of hemodynamic response function 

C = NaN(nx+nh-1,nx); % Convolved time series
% Loop thru volumes
for i = 0:nx-1
    C(i+1:i+nh,i+1) = H*X(i+1); 
end
% Average individual HRFs 
C = nanmean(C,2);
% Truncate end of convolved time series
C = C(1:nx);