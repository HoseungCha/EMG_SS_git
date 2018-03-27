function [f,h_uni]=subplot_fullsize(cols, rows, signal2plot,y_range,titles_arrangements_for_plot)
%  [f,h_uni]=subplot_fullsize(cols, rows, signal2plot,ylim_value)
% clos 열수, rows: 행수, signal2plot: data:cell형식, ylim_value: yrange
% global a;
% global apos

% create new figure window
if nargin<4
    ylim_value = [];
end


f = figure('name', 'EMG Set Visualization', 'NumberTitle', 'off');
set(f,'doublebuffer', 'on', 'resize', 'off');
set(f,'Resize','On');
set(f,'Color',[1 1 1]);

% increase figure width for additional axes
fpos = get(gcf, 'position');
scrnsz = get(0, 'screensize');
% fwidth = min([fpos(3)*cols, scrnsz(3)-20]);
% fheight = scrnsz(4)-100; % maintain aspect ratio
set(gcf, 'position', scrnsz)

% setup all axes
buf = 0.10/cols; % buffer between axes & between left edge of figure and axes
awidth = (1-buf*(cols+1)-.08/cols)/cols; % width of all axes
aidx = 1;
rowidx = 1;
apos=cell(rows,cols);
a=cell(rows,cols);

while aidx <= cols*rows
    for i = 0:cols-1
        if aidx+i <= cols*rows
            start = buf + buf*i + awidth*i;
            apos{aidx+i} = [start 1-(awidth+0.05)*(rowidx) awidth awidth];
            a{aidx+i} = axes('position', apos{aidx+i});
        end
    end
    rowidx = rowidx + 1; % increment row
    aidx = aidx + cols;  % increment index of axes
    if (rowidx==floor(1/awidth))
        break;
    end
end

% make plots
for i = 1:rows
    for col = 1:cols
        
        axes(a{cols*(i-1)+col});
        signal = signal2plot{i, col};
        
        plot(signal);
        axis('on');
        if i==1
            title(titles_arrangements_for_plot{i,col});
        end
        set(a{cols*(i-1)+col},'XTickLabel',[])
        set(a{cols*(i-1)+col},'YTickLabel',[])
        ylim([0 500]);


        %         axis('equal');
        grid on;    
        if nargin>4
            ylim(y_range(col,:));  
            xlim([0, length(signal)]);
        end
    end
end

end

