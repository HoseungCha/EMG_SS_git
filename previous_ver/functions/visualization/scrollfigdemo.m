function [f,h_uni,ax,axis_pos]=scrollfigdemo(cols, rows, signal2plot,ylim_value,titles_arrangements_for_plot)
%  [f,h_uni]=scrollfigdemo(cols, rows, signal2plot,ylim_value)
% clos 열수, rows: 행수, signal2plot: data:cell형식, ylim_value: yrange
global a;
global apos
% Created by Evan Brooks, evan.brooks@wpafb.af.mil
%
% Adaptation of scrollplotdemo by Steven Lord:
% -> Created by Steven Lord, slord@mathworks.com
% -> Uploaded to MATLAB Central
% -> http://www.mathworks.com/matlabcentral
% -> 7 May 2002
% ->
% -> Permission is granted to adapt this code for your own use.
% -> However, if it is reposted this message must be intact.
%

% create new figure window
if nargin<4
    ylim_value = [];
else nargin<5
    titles_arrangements_for_plot=cell(cols,rows);
    for i_cols=1:cols
        for i_rows=1:rows
        titles_arrangements_for_plot{i_cols,i_rows}='None';
        end
    end
        
end


f = figure('name', 'EMG Set Visualization', 'NumberTitle', 'off');
set(f,'doublebuffer', 'on', 'resize', 'off');
set(f,'Resize','On');
set(f,'Color',[1 1 1]);

% set columns of plots


% increase figure width for additional axes
fpos = get(gcf, 'position');
scrnsz = get(0, 'screensize');
fwidth = min([fpos(3)*cols, scrnsz(3)-20]);
fheight = scrnsz(4)-100; % maintain aspect ratio
set(gcf, 'position', [10 50 fwidth fheight])

% setup all axes
buf = 0.10/cols; % buffer between axes & between left edge of figure and axes
awidth = (1-buf*(cols+1)-.08/cols)/cols; % width of all axes
aidx = 1;
rowidx = 1;
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
end

% make plots
for i = 1:rows
    for col = 1:cols

        axes(a{cols*(i-1)+col});
%         subaxis(4, 8, i, 'Spacing', 0.05, 'Padding', 0, 'Margin', 0.05);
        signal = signal2plot{i, col};
        
        plot(signal);
        if i==1
            title(titles_arrangements_for_plot{col,i});
        end
        set(a{cols*(i-1)+col},'XTickLabel',[]);
        set(a{cols*(i-1)+col},'YTickLabel',[]);

%         axis('tight');
%         [signal_length,~]=max(size(signal));
%         [ylim_max,~]=max(signal);
%         t=linspace(1/params.SamplingFrequency2Use,signal_length/params.SamplingFrequency2Use,signal_length);
        
%         plot(t,signal(:,1));
        axis('on'); 
%         axis('equal'); 
%         xlim([0 signal_length/params.SamplingFrequency2Use]);
        grid on;
        if ~(nargin<4)
        ylim(ylim_value(cols,:));
        xlim([0, length(signal)]);

        end 
    end

end

% determine the position of the scrollbar & its limits
swidth = max([.03/cols, 16/scrnsz(3)]);
ypos = [1-swidth 0 swidth 1];
ymax = 0;
ymin = -(awidth+0.05)*(rows-1);

% % build the callback that will be executed on scrolling
% clbk = '';
% for i = 1:length(a)
% %     line = ['set(',num2str(a{i},'%.13f'),',''position'',[', ...
% %             num2str(apos{i}(1)),' ',num2str(apos{i}(2)),'-get(gcbo,''value'') ', num2str(apos{i}(3)), ...
% %             ' ', num2str(apos{i}(4)),'])'];
% %     gcbo_value=sprintf('-get(gcbo.Value)');
% %     -gcbo.value
%     line=sprintf('a{%d}.Position=[%f, %f, %f-%f, %f,]',...
%         i,apos{i}(1),apos{i}(2),apos{i}(3),val,apos{i}(4));
%     if i ~= length(a)
%         line = [line,','];
%     end
%     clbk = [clbk,line];
% end
ax=a;
axis_pos=apos;

% create the slider
h_uni=uicontrol('style','slider', ...
    'units','normalized','position',ypos, ...
    'callback',@clbk_for_scroll,'min',ymin,'max',ymax,'value',0);
end

% function clbk_for_scroll(hObject,~)
% global a;
% global apos;
% 
% val =  hObject.Value;
% % build the callback that will be executed on scrolling
% clbk = '';
% for i = 1:length(a)
%     %     line = ['set(',num2str(a{i},'%.13f'),',''position'',[', ...
%     %             num2str(apos{i}(1)),' ',num2str(apos{i}(2)),'-get(gcbo,''value'') ', num2str(apos{i}(3)), ...
%     %             ' ', num2str(apos{i}(4)),'])'];
%     %     gcbo_value=sprintf('-get(gcbo.Value)');
%     %     -gcbo.value
%     line=sprintf('a{%d}.Position=[%f, %f-%f, %f, %f,];',...
%         i,apos{i}(1),apos{i}(2),val,apos{i}(3),apos{i}(4));
%     if i ~= length(a)
%         line = [line,','];
%     end
%     clbk = [clbk,line];
% 
% end
%     eval(clbk);
% 
% end


