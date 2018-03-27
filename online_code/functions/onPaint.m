%--------------------------------------------------------------------------
% Visualization of EMG real-time signal 
%--------------------------------------------------------------------------
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan Im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
%--------------------------------------------------------------------------
function onPaint(  )
global info;
global pd;

try

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%draw second axes
%data_tmp = pd.EMG.data;szProcessedData

if pd.EMG.datasize<=0
    return;
end

data_tmp = pd.EMG.data(1:pd.EMG.datasize,:);
baseline = -data_tmp(1,:);
for i = 1 : info.ch
    if isnan(baseline(i))
        baseline(:,i) = 0;
    end
end
offset = 100;
for i= 1 : info.ch 
    baseline(i) = baseline(i) - (i-1)*offset;
    data_tmp(:,i) = data_tmp(:,i)+baseline(i);
end
plot(info.handles.axes1, data_tmp); 
xlim(info.handles.axes1, [0 info.cq.length_buff]);
line([pd.EMG.index_end, pd.EMG.index_end],...
    get(info.handles.axes1,'ylim'),'parent',info.handles.axes1);

%label Á¶Á¤
set(info.handles.axes1,'xtick',0:info.Fc:info.cq.time_buff*info.Fc);
szXTicks = cell(1,info.cq.time_buff+1);
for i= 1 : info.cq.time_buff
    szXTicks{i} = char('0' + i-1);
end
szXTicks{11} = char('10');
set(info.handles.axes1,'xticklabel',szXTicks);
drawnow;
% drawnow;
% toc;
% disp(pd.EMG.datasize);
catch ex
    struct2cell(ex.stack)'
    myStop;
    keyboard;
end