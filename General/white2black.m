function cmap = white2black(res)
%
% cmap = white2black([res=256])
%
% Returns a white-colour-black colour map with the resolution res, which must be a 
% multiple of 8. By default res is 256. 

if nargin == 0
    res = 256;
end

steps = res/8;
cmap = [linspace(1.0,1.0,steps)' linspace(1.0,1.0,steps)' linspace(1.0,0.0,steps)'; ... % White-Yellow
        linspace(1.0,1.0,steps)' linspace(1.0,0.0,steps)' linspace(0.0,0.0,steps)'; ... % Yellow-Red       
        linspace(1.0,0.0,steps)' linspace(0.0,1.0,steps)' linspace(0.0,0.0,steps)'; ... % Red-Green       
        linspace(0.0,0.0,steps)' linspace(1.0,1.0,steps)' linspace(0.0,1.0,steps)'; ... % Green-Cyan       
        linspace(0.0,0.0,steps)' linspace(1.0,0.0,steps)' linspace(1.0,1.0,steps)'; ... % Cyan-Blue       
        linspace(0.0,0.7,steps)' linspace(0.0,0.7,steps)' linspace(1.0,0.7,steps)'; ... % Blue-Light Grey       
        linspace(0.7,0.3,steps)' linspace(0.7,0.3,steps)' linspace(0.7,0.3,steps)'; ... % Light Grey-Dark Grey       
        linspace(0.3,0.0,steps)' linspace(0.3,0.0,steps)' linspace(0.3,0.0,steps)'; ... % Dark Grey-Black       
];    

