% Write data into a file in MSVMpack format
function [status, nb_categories] = writemsvmdata(filename, X,Y)
	% Warning: this function erase the file 'filename'
	status = 0;
	nb_categories = 0;
	
	[N,d] = size(X);

	if nargin < 2
		Y = ones(N,1);	% dummy labels if not provided
	end

	fp = fopen(filename,'w'); 
	
	if fp == -1
		disp('Error opening file:');
		filename
		status = -1;
		return;
	end
	
	fprintf(fp, '%d\n',N);	% nb of data
	fprintf(fp, '%d\n',d);	% nb of features
	
	for i=1:N
		fprintf(fp,'%f ',X(i,:));	% write features
		fprintf(fp,'%d\n', Y(i));	% write label
	end
	
	fclose(fp);
	
	nb_categories = max(Y); % only true if Y is provided
end
