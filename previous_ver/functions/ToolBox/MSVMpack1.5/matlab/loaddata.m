%% MSVMpack - load data function
%
%	dataset = loaddata( 'datafile' ) 
% 
%  Loads a data file in MSVMpack format into a dataset structure:
%
%   dataset.name : name of data file
%      dataset.Q : number of categories in data set
%      dataset.X : matrix of features (nb_data x nb_features)
%      dataset.Y : vector of labels (nb_data x 1)
%
function [dataset] = loaddata(datafile) 
	
	fp = fopen(datafile, 'r');
	if fp == -1
		disp('Error opening data file:');
		datafile
		return;
	end
	
	dataset.name = datafile; 
	
	dataset.nb_data = fscanf(fp, '%d', 1);
	dataset.dim = fscanf(fp, '%d', 1);	
	
	dataset.X = zeros(dataset.nb_data,dataset.dim);
	dataset.Y = zeros(dataset.nb_data,1);	
	for i=1:dataset.nb_data
		dataset.X(i,:) = ( fscanf(fp,'%f', dataset.dim) )';
		dataset.Y(i) = fscanf(fp, '%f', 1);
	end

	fclose(fp);
	
	% Make labels into [1,Q]
	minY = min(dataset.Y) ;
	if minY ~= 1
		dataset.Y = dataset.Y - minY + 1;
	end
	
	dataset.Q = max(dataset.Y); 		
		
end
