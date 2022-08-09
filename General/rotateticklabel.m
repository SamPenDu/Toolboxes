function th=rotateticklabel(h,rot,ofs)
%ROTATETICKLABEL rotates tick labels
%   TH=ROTATETICKLABEL(H,ROT) 

%set the default rotation if user doesn't specify
if nargin==1
    rot=90;
end
if nargin < 3
    ofs = 1;
end
%make sure the rotation is in the range 0:360 (brute force method)
while rot>360
    rot=rot-360;
end
while rot<0
    rot=rot+360;
end
%get current tick labels
a=get(h,'XTickLabel');
f=get(h,'FontName');
s=get(h,'FontSize');
%erase current tick labels from figure
set(h,'XTickLabel',[]);
%get tick label positions
b=get(h,'XTick');
c=get(h,'YTick');
%make new tick labels
if rot<180
    th=text(b,repmat(c(1)-(ofs/10)*(c(2)-c(1)),length(b),1),a,'HorizontalAlignment','right','rotation',rot,'FontName',f,'FontSize',s);
else
    th=text(b,repmat(c(1)-(ofs/10)*(c(2)-c(1)),length(b),1),a,'HorizontalAlignment','left','rotation',rot,'FontName',f,'FontSize',s);
end

