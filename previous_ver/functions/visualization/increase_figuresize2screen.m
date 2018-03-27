function f=increase_figuresize2screen(figurename)
f = figure('name', figurename, 'NumberTitle', 'off');
set(f,'doublebuffer', 'on', 'resize', 'off');
set(f,'Resize','On');
set(f,'Color',[1 1 1]);

% increase figure width for additional axes
fpos = get(gcf, 'position');
scrnsz = get(0, 'screensize');
% fwidth = min([fpos(3)*cols, scrnsz(3)-20]);
% fheight = scrnsz(4)-100; % maintain aspect ratio
set(gcf, 'position', scrnsz)
end