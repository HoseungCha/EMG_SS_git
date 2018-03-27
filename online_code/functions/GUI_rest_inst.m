%--------------------------------------------------------------------------
% Rest instruction GUI code
%--------------------------------------------------------------------------
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan Im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
%--------------------------------------------------------------------------
function GUI_rest_inst()
global info;
try
    %% GUI Rest, time check
    GUI_rest_timestart = toc(info.timer.RestInst.UserData)
    
    %% presentation of facial expression pic.
    for i_FE=1:info.N_FE
        info.im_h(i_FE).Visible='off';
    end
    info.im_h(6).Visible = 'on';
    
    %% instruction of resting
    info.handles.edit_insturction.String = ...
        sprintf('Please release the tension in your face');
    %% when finished
    if(info.FE_end_sign)
        if info.handles.radiobutton_train.Value == 1 % when train finished
            info.handles.edit_insturction.String = ...
                sprintf('Registeration is being conducted. please wait.');
            myStop(); % timer ²ô±â
            %             closePreview(info.cam); % cam ²ô±â
            find_feat_and_train(); %% train LDA%%%%%%%%%%%%%%%%%%%%%%%%%%
            
        elseif info.handles.radiobutton_test.Value == 1% when test finished
            info.handles.edit_insturction.String = ...
                sprintf('A session has been finished.');
            myStop();
            %             closePreview(info.cam);
            result = info.test_result;
            %             info = rmfield(info,{'handles','info.cam'});
            uisave({'info','result'},fullfile(cd,'online_code',...
                'result',datestr(now,'yymmdd_'))); % saving results
        end
    end
    info.FE_start_sign = 0;
catch ex
    struct2cell(ex.stack)'
    myStop;
    keyboard;
end
end