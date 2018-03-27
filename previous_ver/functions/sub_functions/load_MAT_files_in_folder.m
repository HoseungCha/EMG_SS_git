%----------------------------------------------------------------------
% [data,path] = load_mat_files_in_folder(filepath)
% option 1: data path,  option2:data loading,만 반환
% 특정 path에 있는 모든 파일을 읽는다.
% 읽어들인 파일은 cell data 형식으로 저장된다.
%----------------------------------------------------------------------
% by Won-Du Chang, ph.D, 
% Post-Doc @  Department of Biomedical Engineering, Hanyang University
% 12cross@gmail.com
%---------------------------------------------------------------------
function [data,path] = load_MAT_files_in_folder(filepath,option)
    list = dir([filepath '/*.mat']);
    nFile = size(list,1);
    path = cell(nFile,1);   % . 과 .. 을 제거
    count = 1;
    data=cell(1);
    for i=1:nFile
        if ( strcmp(list(i).name,'.')==1 || strcmp(list(i).name,'..')==1)
            continue;
        end
        path{count,1} = [filepath '/' list(i).name];
        if option==2
        data{count,1} = load([filepath '/' list(i).name]);
        end
%         Data{count} = data{1,count}.data;
        count = count +1;
    end
end