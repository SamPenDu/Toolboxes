function [ConOut, DataOut] = NonRedundantConnectogram(ConIn, DataIn)
%
% [ConOut, DataOut] = DelaunayConnectogram(ConIn, [DataIn])
%
% Removes the redundant connections from the connectogram ConIn (and from
% DataIn if this is defined, otherwise this returns an empty cell array).
%

if nargin < 2
    DataOut = {};
else
    DataOut = DataIn;
end
ConOut = ConIn;

% Loop thru nodes
for n = 1:length(ConIn)
    % Loop thru targets
    for t = 1:length(ConOut{n})
        % Remove redundant back-connection
        x = find(ConOut{ConOut{n}(t)} == n); % Find back-connection
        if ~isempty(x)
            ConOut{ConOut{n}(t)}(x) = [];
            if nargin > 1
                DataOut{ConOut{n}(t)}(x) = [];
            end
        end
    end
end