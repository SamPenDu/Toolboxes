function frameDur = getFrameDuration
%frameDur = getFrameDuration
% Returns the frame duration (Cogent must be initialized!)
%

clearpict(1);
t1 = drawpict(1);
clearpict(1);
t2 = drawpict(1);

frameDur = (t2-t1);
