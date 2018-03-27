%--------------------------------------------------------------------------
% Control mode에서 Train/Test버튼에 따라 Instruction과 Online Test
% Pannel에 해당 모드가 표시되도록 한다. 
%--------------------------------------------------------------------------
% by Ho-Seung Cha, Ph.D Student
% Ph.D candidate @ Department of Biomedical Engineering, Hanyang University
% hoseungcha@gmail.com
%--------------------------------------------------------------------------
function GUI_mode_presentation(handles)
if handles.radiobutton_train.Value==1
    handles.edit_insturction.String = [handles.radiobutton_train.String,...
        ' mode'];
    handles.edit_model_input.Enable = 'off';
    handles.edit_classification.String = sprintf('Train Mode ');
            
elseif handles.radiobutton_test.Value==1
    handles.edit_insturction.String = [handles.radiobutton_test.String,...
        ' mode'];
    handles.edit_model_input.Enable = 'on';
    handles.edit_classification.String = sprintf('Test Mode');
end
end