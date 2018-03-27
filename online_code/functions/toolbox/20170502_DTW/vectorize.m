function vd = vectorize(d)
    len = length(d);
    vd = [0; d(2:len) - d(1:len-1)];
end