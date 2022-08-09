function Check_VoxSpace(epifile, roifile)
% This tool for checking if a ROI image and EPI scan are in the same absolute space
% (i.e. they must have the same transformation matrix and same voxel space dimensions).

if nargin == 0
    [epifile epipath] = uigetfile('u*.img;u*.nii;r*.img;r*.nii', 'Select functional scan');
    [roifile roipath] = uigetfile('*.nii;*.img', 'Select ROI or stats image');
    epihdr = spm_vol([epipath filesep epifile]);
    roihdr = spm_vol([roipath filesep roifile]);
else
    epihdr = spm_vol(epifile);
    roihdr = spm_vol(roifile);
end
epi = spm_read_vols(epihdr);
roi = spm_read_vols(roihdr);
disp(' ');
disp('Functional scan')
disp(epihdr(1).mat);
disp('Map image');
disp(roihdr(1).mat);
disp(' ');
disp('''     Move down by one slice');
disp('#     Move up by one slice');
disp('<-    Descrease threshold by 0.1');
disp('->    Increase threshold by 0.1');
disp('[     Descrease threshold by 1');
disp(']     Increase threshold by 1');
disp('I     Toggle nearest-neighbour/bicubic interpolation');
disp('D     Toggle map display on/off');
disp('ESC   Exit program'); disp(' ');

z = floor(size(epi,3)/2);   % Current slice
intrmeth = 'nearest';   % Current interpolation method
dispmap = 'on';   % Currently displaying ROI/T-map
T = 0.8;    % Current threshold

h = figure;
k = 0;  % Key 
while k ~= 27   % Esc closes tool
    % Current slice
    epislc = squeeze(epi(:,:,z));
    epislc = epislc / max(epislc(:));
    if strcmp(dispmap, 'on')
        roipos = squeeze(roi(:,:,z));
        roineg = squeeze(roi(:,:,z));
        roipos(roipos < T) = 0;
        roineg(roineg > -T) = 0;
        roineg = abs(roineg);
        trn = find(roipos == 0);
        roipos(trn) = epislc(trn);
        trn = find(roineg == 0);
        roineg(trn) = epislc(trn);
        roislc = roipos; 
        roislc(:,:,2) = epislc; 
        roislc(:,:,3) = roineg; 
    else
        roislc = repmat(epislc, [1 1 3]);
    end
    
    % Show the image
    set(h, 'Name', [roifile '->' epifile ' (z=' num2str(z) ', T=' num2str(T) '), Interpolation: ' intrmeth ', Display: ' dispmap]);
    imshow(imresize(roislc,5, intrmeth)); 
    
    b = waitforbuttonpress;
    k = get(h,'CurrentCharacter');
    switch k
        case {''''; '@'} 
            z = z + 1;
        case {'#'; '~'}
            z = z - 1;
        case {'-'; '_'}
            T = T - 0.1;
        case {'='; '+'}
            T = T + 0.1;
        case {'['; '{'}
            T = T - 1;
        case {']'; '}'}
            T = T + 1;
        case {'i' 'I'}
            if strcmp(intrmeth, 'nearest')
                intrmeth = 'bicubic';
            else
                intrmeth = 'nearest';
            end
        case {'d'; 'D'}
            if strcmp(dispmap, 'on')
                dispmap = 'off';
            else
                dispmap = 'on';
            end
    end
    if z < 1
        z = 1;
    end
    if z > size(epi,3)
        z = size(epi,3);
    end
    if T < 0
        T = 0;
    end
    
    text(1,1,'Text');
    text(size(epi,2)-2, 3, num2str(z));
    set(gca,'Color',[1 1 1]);
end

close(h);