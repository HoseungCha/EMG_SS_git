%--------------------------------------------------------------------------
% by Ho-Seung Cha, Ph.D Student
% Ph.D candidate @ Department of Biomedical Engineering, Hanyang University
% hoseungcha@gmail.com
%--------------------------------------------------------------------------
function GUI_rest_inst()
    global info;
    GUI_rest_timestart = toc(info.timer.RestInst.UserData)    
    for i_FE=1:info.N_FE
        info.im_h(i_FE).Visible='off';
    end
    info.im_h(6).Visible = 'on';
            
    info.handles.edit_insturction.String = ...
        sprintf('Please release the tension in your face');
    if(info.FE_end_sign)
        if info.handles.radiobutton_train.Value == 1
            info.handles.edit_insturction.String = ...
            sprintf('Registeration is being conducted. please wait.');
            myStop(); % timer ²ô±â
%             closePreview(info.cam); % cam ²ô±â
            find_feat_and_train(); % training ¼öÇà ¹× model ÀúÀå
        elseif info.handles.radiobutton_test.Value == 1
            info.handles.edit_insturction.String = ...
            sprintf('A session has been finished.');
            myStop();
%             closePreview(info.cam);
            result = info.test_result;
%             info = rmfield(info,{'handles','info.cam'});
            uisave({'info','result'},fullfile(cd,'online_code','result',datestr(now,'yymmdd_')));
        end
    end
    info.FE_start_sign = 0;
%     catch me
%         a=1;
%     end
end