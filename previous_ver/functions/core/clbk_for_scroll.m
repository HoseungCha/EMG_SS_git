function clbk_for_scroll(hObject,event)
global a;
global apos;

val =  hObject.Value;
% build the callback that will be executed on scrolling
clbk = '';
for i = 1:length(a)
    %     line = ['set(',num2str(a{i},'%.13f'),',''position'',[', ...
    %             num2str(apos{i}(1)),' ',num2str(apos{i}(2)),'-get(gcbo,''value'') ', num2str(apos{i}(3)), ...
    %             ' ', num2str(apos{i}(4)),'])'];
    %     gcbo_value=sprintf('-get(gcbo.Value)');
    %     -gcbo.value
    line=sprintf('a{%d}.Position=[%f, %f-%f, %f, %f,];',...
        i,apos{i}(1),apos{i}(2),val,apos{i}(3),apos{i}(4));
    if i ~= length(a)
        line = [line,','];
    end
    clbk = [clbk,line];
    
end
eval(clbk);

end