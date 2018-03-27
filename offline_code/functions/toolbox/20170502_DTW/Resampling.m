% designed & coded by Dr. Won-Du Chang
% last modified 2017.05.03
function [d_new,x_new,x_old] = Resampling(data,nDiv)
    nLenOld = size(data,1);
    nLenNew = (nLenOld - 1) * nDiv + 1;
    d_new = zeros(nLenNew,1);
    d_new(1) = data(1);
    for i=2:nLenOld
        for j=1:nDiv-1
            factor = (data(i) - data(i-1))/nDiv;
            pos = (i-2) * nDiv + 1 + j;
            d_new(pos)= data(i-1) + factor * j;
        end
        pos = pos +1;
        d_new(pos) = data(i);
    end
    x_new = 0:nLenNew-1;
    x_new = x_new/nDiv;
    x_old = 0:nLenOld-1;
end