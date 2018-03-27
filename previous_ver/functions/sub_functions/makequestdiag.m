function answer=makequestdiag(Someting2Ask,title)
% Construct a questdlg with three options
choice = questdlg(Someting2Ask, ...
	title, ...
	'Yes','No','No');
% Handle response
switch choice
    case 'Yes'
        answer = 1;
    case 'No'
        answer = 2;
end