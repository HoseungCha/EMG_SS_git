function draw_session_signal()
% This function has no output args.
% g_handles    handle to figures
% EOG          EOG signal containing matrix (N_data, N_components)

global g_handles;
global params;
global buffer;

% buffer.session_data{buffer.n_session, 1}.session = buffer.n_session;
% buffer.session_data{buffer.n_session, 1}.saved_time = fix(clock);
% buffer.session_data{buffer.n_session, 1}.n_data = n_data_sum;
% buffer.session_data{buffer.n_session, 1}.data_queue = data_queue;


y_range = params.y_range;
% EOG = circshift(buffer.dataqueue.data, -buffer.dataqueue.index_start+1);
EOG=buffer.session_data{buffer.n_session, 1}.data_queue;
offset=100;
% Current Signal Plot
cla(g_handles.current_calibration);

% for i= -(params.CompNum-3):1:params.CompNum-3
plot(g_handles.current_calibration, EOG(:,1)-offset*2, '-b');
hold(g_handles.current_calibration, 'on');
plot(g_handles.current_calibration, EOG(:,2)-offset*1, '-r');
hold(g_handles.current_calibration, 'on');
plot(g_handles.current_calibration, EOG(:,3), '-b');
hold(g_handles.current_calibration, 'on');
plot(g_handles.current_calibration, EOG(:,4)+offset*1, '-r');
hold(g_handles.current_calibration, 'on');
plot(g_handles.current_calibration, EOG(:,5)+offset*2, '-b');
% plot(g_handles.current_calibration, EOG(:,2)+y_range, '-r');

% Legend
text(0.01, 0.10,'Bp12', 'Parent', g_handles.current_calibration, 'Units','normalized', 'Color', 'b', 'FontName', 'Cambria', 'FontSize', 20, 'FontWeight', 'bold');
text(0.01, 0.30,'Bp34', 'Parent', g_handles.current_calibration, 'Units','normalized', 'Color', 'r', 'FontName', 'Cambria', 'FontSize', 20, 'FontWeight', 'bold');
text(0.01, 0.50,'Bp78', 'Parent', g_handles.current_calibration, 'Units','normalized', 'Color', 'b', 'FontName', 'Cambria', 'FontSize', 20, 'FontWeight', 'bold');
text(0.01, 0.70,'Uni5', 'Parent', g_handles.current_calibration, 'Units','normalized', 'Color', 'r', 'FontName', 'Cambria', 'FontSize', 20, 'FontWeight', 'bold');
text(0.01, 0.90,'Uni6', 'Parent', g_handles.current_calibration, 'Units','normalized', 'Color', 'b', 'FontName', 'Cambria', 'FontSize', 20, 'FontWeight', 'bold');

% legend(g_handles.current_calibration, {'EOG_x', 'EOG_y'}, ...
%     'Orientation', 'horizontal', 'Location', 'southwest', 'FontSize',8);

% Draw Grids
set(g_handles.current_calibration,'TickLength', [0 0]);

tickValues = 0:fix(1/params.DelayTime)*params.BufferLength_Biosemi:params.ResultLength;
set(g_handles.current_calibration,'XTick', tickValues);
set(g_handles.current_calibration,'YTick', []);
grid(g_handles.current_calibration, 'on');
set(g_handles.current_calibration, 'box', 'on');

% plot offset
for i= -(params.CompNum-3):1:params.CompNum-3
plot(g_handles.current_calibration, [0 buffer.session_data{1, 1}.n_data ], [offset*i offset*i], 'color', 'black','LineWidth',2);
hold(g_handles.current_calibration,'on');
end
% plot(g_handles.current_calibration, [0 params.ResultLength], [y_range y_range], 'color', 'black');

% X, Y Range Setting
xlim(g_handles.current_calibration, [0 buffer.session_data{1, 1}.n_data]);

% Draw Blink Detection Rage
drawRange();

hold(g_handles.current_calibration, 'off');

end

function drawRange()
global params;
global buffer;
global g_handles;

p = params.blink;
b = buffer.blink;

% Plot related Parameters
mark_position = 0.9; % Relative Position of Blink Detection Mark : Bottom 0 to Top 1
line_style = 'box'; % either horizon or vertical
alpha = 0.1;
color = [1 0 0];

% The number of ranges
ranges = blink_range_position_conversion();
nRange = size(ranges, 1);

y = get(g_handles.current_calibration,'YLim');

if nRange > 0
    for i=1:nRange
        pos = ranges(i, :);
        
        if strcmp(line_style, 'horizon')
            y_h = ((1 - mark_position) * y(1) + mark_position * y(2));
            plot(g_handles.current_calibration, pos, [y_h, y_h], '-r', 'LineWidth', 2);
        
        elseif strcmp(line_style, 'vertical')
            plot(g_handles.current_calibration, [pos(1), pos(1)], y, ':r', 'LineWidth', 1);
            plot(g_handles.current_calibration, [pos(2), pos(2)], y, ':r', 'LineWidth', 1);
        
        elseif strcmp(line_style, 'box')
            hold(g_handles.current_calibration, 'on');
            H = area(g_handles.current_calibration, pos, [y(2), y(2)]);
            H2 = area(g_handles.current_calibration, pos, [y(1), y(1)]);
            hold(g_handles.current_calibration, 'off');
            
            % Set alpha value for the area
            h=get(H,'children');
            set(h,'FaceAlpha', alpha, 'FaceColor', color, 'LineStyle', 'none');
            h=get(H2,'children');
            set(h,'FaceAlpha', alpha, 'FaceColor', color, 'LineStyle', 'none');
        end
    end
end
end