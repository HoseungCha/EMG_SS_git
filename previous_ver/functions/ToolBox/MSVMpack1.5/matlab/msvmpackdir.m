%% Returns MSVMpack directory
%
function [directory] = msvmpackdir() 
	if(strncmp(computer('arch'), 'win', 3))
		directory = strrep(mfilename('fullpath') , '\matlab\msvmpackdir', '\Windows\bin');
	else
		directory = strrep(mfilename('fullpath') , '/matlab/msvmpackdir', '');
	end
end
