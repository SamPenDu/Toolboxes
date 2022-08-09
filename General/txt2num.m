function data = txt2num(txt)
%converts text data into an array of numeric values

    data = [];
    
    for s = 1:length(txt)
        str = cell2mat(txt(s));
        dat = str2num(str);
        data = [data; dat];
    end
