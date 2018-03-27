function draw_realtime_trigger(handle_name)
% This function has no output args.
% g_handles    handle to figures
% EMG          EMG signal containing matrix (N_data, N_components)

global params;
global buffer;
global g_handles;

EMG_channel_length=params.CompNum;
offset=50;
EMG = circshift(buffer.dataqueue.data, -buffer.dataqueue.index_start+1);

% Current Signal Plot
cla(handle_name);
    i_comp=EMG_channel_length+3;
    plot(handle_name, EMG(:,i_comp));

% Legend
legend(handle_name,'Trigger');
% legend(handle_name, {'EMG_x', 'EMG_y'}, ...
%     'Orientation', 'horizontal', 'Location', 'southwest', 'FontSize',8);

% Draw Grids
% set(handle_name,'TickLength', [0 0]);

tickValues = 0:fix(1/params.DelayTime)*params.BufferLength_Biosemi:params.QueueLength;

% hxLabel=get(handle_name,'XLabel');
% set(hxLabel,'FontSize',10);
set(handle_name,'XTickLabel',[])
set(handle_name,'XTick', tickValues);
set(handle_name,'YTick', []);
grid(handle_name, 'on');
set(handle_name, 'box', 'on');

% plot(handle_name, [0 params.QueueLength], [0 0], 'color', 'black');
% plot(handle_name, [0 params.QueueLength], [y_range y_range], 'color', 'black');

% X, Y Range Setting
xlim(handle_name, [0 params.QueueLength]);

hold(handle_name, 'off');

end


