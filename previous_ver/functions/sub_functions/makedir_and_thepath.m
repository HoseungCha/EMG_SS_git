% ������ ����� ���ÿ�, ������ ��θ� ��ȯ �Ѵ�
% outputpath = makedir_and_thepath(currentpath,name) 
function outputpath = makedir_and_thepath(currentpath,name)
    mkdir(currentpath,name); % ��ξȿ�, �ڱ� ���� �����
    outputpath = fullfile(currentpath,name); % �� ���� ��� ����
end