function draw_realtime_signal(handle_name)
% This function has no output args.
% g_handles    handle to figures
% EMG          EMG signal containing matrix (N_data, N_components)

global params;
global buffer;

offset=0.2*1E9;
EMG = circshift(buffer.dataqueue.data, -buffer.dataqueue.index_start+1);
if params.bandpass_filtering_after_epoch
     % filtering
    b=params.filter.b;
    Vriable=params.filter.Vriable;
    EMG=simple_filter(EMG,b,Vriable);
end

% Current Signal Plot
cla(handle_name);
for i_comp=1:params.CompNum
    plot(handle_name, EMG(:,i_comp)-offset*(i_comp-1));
    hold(handle_name, 'on');
end
% Legend
legend(handle_name,'BP12','BP13','BP14','BP23','BP24','BP34',...
'Uni1','Uni2','Uni3','Uni4');
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


