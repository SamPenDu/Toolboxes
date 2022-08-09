function imgOut = GaussianEnvelope(imgIn, StdDev)
%imgOut = GaussianEnvelope(imgIn, StdDev)
%
% Returns image imgIn within Gaussian envelope with standard deviation StdDev.
%

imgOut = imgIn;
[my mx] = size(imgIn);
cx = mx/2;
cy = my/2;

[X Y] = meshgrid([-cx:-1 1:cx], [-cy:-1 1:cy]); 
Gaussian = exp(-((X.^2)./(2*StdDev.^2))-((Y.^2)./(2*StdDev.^2)));

imgOut = imgIn .* Gaussian;

