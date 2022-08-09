function samlegend(conds, cols, locat)
%samlegend(conds, cols, [locat])
%
% Display a legend when the native method breaks down...
% (Such as is the case for multiple errorplots)
%
% Unlike native method you need to call this *before* plotting data!
%

if nargin < 3
    locat = 'Best';
end

hold on;
for i=1:length(conds)
    plot(Inf, 'Color', cols(i,:), 'LineWidth', 2);
end
legend(conds, 'Location', locat);

