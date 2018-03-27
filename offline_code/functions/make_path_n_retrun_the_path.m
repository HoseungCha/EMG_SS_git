%----------------------------------------------------------------------
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan Im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
%---------------------------------------------------------------------
function path_made = make_path_n_retrun_the_path(path2save,folder_name2make)
    % path2save�� filder_name2make�� �̸����� ���� ����
    mkdir(path2save,folder_name2make);
    % ���� ������ path �޾ƿ�
    path_made = fullfile(path2save,folder_name2make);
end