function LogMar = Snellen2LogMar(Snellen)
%
% LogMar = Snellen2LogMar(Snellen)
%
% Converts Snellen acuity given as a string (e.g. '20/20') into logMAR.
% You can use either Imperial units ('20/20') or metric units ('6/6') or in
% fact any other fraction expressing the ratio of angular resolution of
% normal to tested visual acuity.
%

MinAngRes = eval(Snellen);
LogMar = -log10(MinAngRes);

