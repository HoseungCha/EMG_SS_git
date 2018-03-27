function fast_subplot(data,dimension,title_name)
% dimension방향 (n) 으로 (nX1) subplot을 그려줌
% title, cell data 형식 (n과 일치해야 함)

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
