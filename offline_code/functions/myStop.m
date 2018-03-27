%--------------------------------------------------------------------------
% 종료처리함수
%--------------------------------------------------------------------------
% by Ho-Seung Cha, Ph.D Student
% Ph.D candidate @ Department of Biomedical Engineering, Hanyang University
% hoseungcha@gmail.com
%--------------------------------------------------------------------------
function myStop()
    global info;
%     global bStarted;
    
    if ~isempty(timerfind)
        stop(timerfind);
%         delete(timerfind);
    end
%     bStarted =0;
    
%     hObject =  findobj(info.handles.pushbutton_start);
%     if isvalid(hObject)
%         hObject.String = 'Start';
%     end
    
end