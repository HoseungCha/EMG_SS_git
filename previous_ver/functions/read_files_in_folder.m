%----------------------------------------------------------------------
% [data] = load_txt_files_in_folder(filepath,data_format)
%
% Ư�� path�� �ִ� ��� ������ �д´�.
% �о���� ������ cell data �������� ����ȴ�.
%----------------------------------------------------------------------
% by Won-Du Chang, ph.D, 
% Post-Doc @  Department of Biomedical Engineering, Hanyang University
% 12cross@gmail.com
%---------------------------------------------------------------------
function [pathname,fname] = read_files_in_folder(filepath,data_format)
    list = dir([filepath '/*.', data_format]);
    nFile = size(list,1);
    pathname = cell(1,nFile);   % . �� .. �� ����
    fname=cell(1,nFile);
    count = 1;
    for i=1:nFile
        if ( strcmp(list(i).name,'.')==1 || strcmp(list(i).name,'..')==1)
            continue;
        end
        pathname{count} = [filepath '/' list(i).name];
        fname{count} = [list(i).name];
%         Data{count} = data{1,count}.data;
        count = count +1;
    end
end