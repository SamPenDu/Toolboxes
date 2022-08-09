function RndDotKin = RandomDotKinetogram(Coherence, Direction, Velocity, NumDots, Width, LifeTime)
%RndDotKin = RandomDotKinetogram(Coherence, Direction, Velocity, NumDots, [Width, LifeTime])
%
% Generates a random dot kinetogram stimulus structure. 
% 
% Parameters:
%   Coherence :     Proportion of coherently moving dots
%   Direction :     Direction of coherently moving dots
%   Velocity :      Velocity of moving dots (scalar)
%                       If dots with different velocities are required,
%                       you need to change the Velocity field directly.
%   NumDots :       Total number of dots in display
%   Width :         Width of the dots (optional, default = 6)
%                       This makes all the dots the same size, but the
%                       field can be changed to individualize dot sizes.
%   LifeTime :      Life time of the dots. (optional, default = Inf)
%
% Returns a stimulus structure. These structures are organised in much the
% same way as those of Gabor fields, however, there are differences:
%
%   'Contrast' defines the colour, if it is a N x 3 matrix.
%   'IsContour' defines whether a dot belongs to the background!
%   
% While these field names may seem misleading, this allows you to use the 
% same functions as for Gabor fields, e.g. BackgroundPattern. Essentially, 
% the background elements in a Gabor field are the coherent dots in a RDK!
%
%   The field 'Width' defines the width of dots. It is equivalent but not
%   the same as 'Sigma' for Gabor fields, as this defines a Gaussian.
%
%   'LifeTime' defines the lifetime of dots in frames. 'Age' is a vector 
%   containing the age of dots. By default, the lifetime is infinite, and 
%   the dot ages are thus irrelevant.
%

if nargin < 5
    Width = 6;
    LifeTime = Inf;
elseif nargin < 6
    LifeTime = Inf;
end

NumCohDots = round(NumDots*Coherence);

RndDotKin = struct;

X = []; Y = [];
for i = 1 : NumDots
    x = rand*2-1;
    y = rand*2-1;
    while sqrt(x^2 + y^2) > 1
        x = rand*2-1;
        y = rand*2-1;
    end
    X(i) = x; 
    Y(i) = y; 
end

RndDotKin.N = NumDots;
RndDotKin.X = X';
RndDotKin.Y = Y';
RndDotKin.Theta = [Direction * ones(NumCohDots,1); RandOri(NumDots-NumCohDots,1)];
RndDotKin.Collinear = RndDotKin.Theta;
RndDotKin.Contrast = RandSign(NumDots,1);
RndDotKin.IsContour = [zeros(NumCohDots,1); ones(NumDots-NumCohDots,1)];
RndDotKin.Velocity = ones(NumDots,1) * Velocity/1000;
RndDotKin.Width = ones(NumDots,1) * Width;
RndDotKin.LifeTime = LifeTime;
RndDotKin.Annulus = 0;

if isinf(LifeTime) 
    RndDotKin.Age = ones(NumDots,1) * Inf;
else
    RndDotKin.Age = round(rand(NumDots,1) * LifeTime);
end    
