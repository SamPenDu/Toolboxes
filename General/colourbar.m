function colourbar(Label, Crange, Ctick, Cticklabel)
%
% colourbar(Label, Crange, Ctick, Cticklabel)
%
% Adds a colour bar labelled as Label within the range defined by Crnage
% and with the tick marks and labels defined by Ctick and Cticklabels.
% All but Label is optional. If Cticklabels is undefined it 
%

cb = colorbar;
set(get(cb,'label'), 'string', Label);
if nargin >= 2
    caxis(Crange);
end
if nargin >= 3
    set(cb, 'ytick', Ctick);
end
if nargin >= 4
    set(cb, 'yticklabel', Cticklabel);
end
