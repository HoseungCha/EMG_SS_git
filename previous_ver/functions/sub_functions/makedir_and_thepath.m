% 폴더를 만듬과 동시에, 폴더의 경로를 반환 한다
% outputpath = makedir_and_thepath(currentpath,name) 
function outputpath = makedir_and_thepath(currentpath,name)
    mkdir(currentpath,name); % 경로안에, 자극 폴더 만들기
    outputpath = fullfile(currentpath,name); % 위 폴더 경로 지정
end