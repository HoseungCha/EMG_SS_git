% 화면 display 를 위한 함수
function onPaint(  )
%ONPAINT 이 함수의 요약 설명 위치
%   그림 담당 함수
% tic;
global info;
global pd;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%draw second axes
%data_tmp = pd.EMG.data;szProcessedData

if pd.EMG.datasize<=0
    return;
end

data_tmp = pd.EMG.data(1:pd.EMG.datasize,:);
baseline = -data_tmp(1,:);
for i = 1 : info.Ch
    if isnan(baseline(i))
        baseline(:,i) = 0;
    end
end
offset = 100;
for i= 1 : info.Ch 
    baseline(i) = baseline(i) - (i-1)*offset;
    data_tmp(:,i) = data_tmp(:,i)+baseline(i);
end
% myStop;
plot(info.handles.axes1, data_tmp); 
xlim(info.handles.axes1, [0 info.cq.length]);
line([pd.EMG.index_end, pd.EMG.index_end],...
    get(info.handles.axes1,'ylim'),'parent',info.handles.axes1);

%label 조정
set(info.handles.axes1,'xtick',0:info.Fc:info.cq.time*info.Fc);
szXTicks = cell(1,info.cq.time+1);
for i= 1 : info.cq.time
    szXTicks{i} = char('0' + i-1);
end
szXTicks{11} = char('10');
set(info.handles.axes1,'xticklabel',szXTicks);
drawnow;
% drawnow;
% toc;
% disp(pd.EMG.datasize);

