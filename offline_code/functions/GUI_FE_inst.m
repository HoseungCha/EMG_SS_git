%--------------------------------------------------------------------------
% by Ho-Seung Cha, Ph.D Student
% Ph.D candidate @ Department of Biomedical Engineering, Hanyang University
% hoseungcha@gmail.com
%--------------------------------------------------------------------------
function GUI_FE_inst()
    
    global info; 
    GUI_FE_timestart = toc(info.timer.FE_train.UserData)
    for i_FE=1:info.N_FE
        info.im_h(i_FE).Visible='off';
    end
    info.im_h(info.FE_order4GUI(1)).Visible = 'on';
            
    info.handles.edit_insturction.String = ...
        sprintf('Please make a %s face for 3 seconds',...
        info.FE_name{info.FE_order4GUI(1)});
%     myStop;
    info.FE_order4GUI = circshift(info.FE_order4GUI,-1 ,2);
    if isequal(info.FE_order4GUI,info.FE_order)
        info.FE_end_sign = 1;
    end
    info.FE_start_sign = 1;
end