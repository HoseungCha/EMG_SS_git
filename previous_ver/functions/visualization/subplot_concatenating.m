function [concatenating_plot_data,CDATA]=subplot_concatenating(data,title4plot,num2plot_on_s,xlimit)
% data: Cell 형식, title4plot: cell 형식, rows:그림갯수(rows) cols:열 개수,
% num2plot_on_s: 스크린에 뛰울 행 갯수
% xlimit=[0 150*60*params.Fs];
[rows,cols]=size(data);
numbers_of_figure=ceil(rows/num2plot_on_s);
for i=1:numbers_of_figure
    
    fig=increase_figuresize2screen('EMG');
    if i==numbers_of_figure
        num2plot_on_s=rows-(numbers_of_figure-1)*numbers_of_figure;
    end
    
    for jj=1:num2plot_on_s*cols
        subplot(num2plot_on_s,cols,jj)
        %         try
        if size(data{num2plot_on_s*(i-1)+jj},2)==2
            plot(data{num2plot_on_s*(i-1)+jj}(:,1),...
                data{num2plot_on_s*(i-1)+jj}(:,2));
        else
            plot(data{num2plot_on_s*(i-1)+jj}');
            ylim([0,200]);
            if nargin==4
                xlim(xlimit);
            end
        end
        title(title4plot{num2plot_on_s*(i-1)+jj});
        %         catch
        %             keyboard
        %         end
        
    end
    F = getframe(fig);
    CDATA{i} = F.cdata;
    close(fig)
end
concatenating_plot_data=cat(1,CDATA{:});
end