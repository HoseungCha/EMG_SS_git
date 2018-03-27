function fast_subplot(data,dimension,title_name)
% dimension���� (n) ���� (nX1) subplot�� �׷���
% title, cell data ���� (n�� ��ġ�ؾ� ��)

figure
N=size(data,dimension);
if nargin<3
    title_name=cell(N,1);
    for i=1:N
        title_name{i}='nonamed';
    end
end
for ii=1:N
    if dimension==1
        subplot(N,1,ii);plot(data(ii,:));
%         title(title_name{ii});
    elseif dimension ==2
        subplot(N,1,ii);plot(data(:,ii));
        title(title_name{ii});
    end
end
end
