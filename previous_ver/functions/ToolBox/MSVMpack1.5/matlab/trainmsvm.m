
%% MSVMpack training function for Matlab
%
%  For default options: 
%
%	model = trainmsvm(X, Y)  
%
%  For full control:
%	
%	model = trainmsvm(X, Y, options) 
%	
%  or 
%	
%	model = trainmsvm(X, Y, options, modelname)
%
%  Inputs: 
%           X : matrix of training data (nb_data x nb_features)
%           Y : vector of training labels (nb_data x 1)  
%     options : string with optional parameters (see below)
%   modelname : string with name of model (used by temporary files)
%
%
%  Other calling method: 
%
%	 model = trainmsvm(dataset)  
%  or
%	model = trainmsvm(dataset, options)
%
%  with a dataset structure obtained from loaddata('datafile').
%
%
%  Optional parameters:
% 
%	 -m	: model type (WW,CS,LLW,MSVM2) (default is MSVM2)
%	 -k	: nature of the kernel function (default is 1)
%	 	  1 -> linear kernel       k(x,z) = x^T z
%	 	  2 -> Gaussian RBF kernel k(x,z) = exp(-||x - z||^2 / 2*par^2)
%	 	  3 -> homogeneous polynomial kernel k(x,z) = (x^T z)^par 
%	 	  4 -> non-homo. polynomial kernel k(x,z) = (x^T z + 1)^par 
%	 	  5 -> custom kernel 1
%	 	  6 -> custom kernel 2
%	 	  7 -> custom kernel 3
%	 -p	: kernel parameter par (default is sqrt(5*dim(x)) (RBF) or 2 (POLY))
%	 -P     : list of space-separated kernel parameters starting with #parameters
%	 -c	: soft-margin (or trade-off) hyperparameter (default C = 10.0)
%	 -C	: list of space-separated hyperparameters C_k (default C_k = C)
%	 -n	: use normalized data for training (mean=0 and std=1 for all features)
%	 -x	: maximal cache memory size in MB (default is 1024)
%	 -t	: number of working threads (default is number of CPUs)
%	 -o	: optimization method: 0 -> Franke-Wolfe (default), 1 -> Rosen
%	 -w	: size of the chunk (default is 10 for WW and 4 for others)
%	 -a	: optimization accuracy within [0,1] (default is 0.98)
%	 -q	: be quiet
%
%
%  Examples (with CS model type, RBF kernel, C=10):
%	
%	model = trainmsvm(X, Y, '-m CS -k 2 -c 10')
%
%	dataset = loaddata('Data/iris.train');
%   model = trainmsvm(dataset, '-m CS -k 2 -c 10')
%	

function [model] = trainmsvm(X, Y, options, modelname) 

	if isstruct(X)
		% calling method : trainmsvm(dataset, options)
		dataset = X;
		modelname = dataset.name;
		X = dataset.X;
		Y = dataset.Y;
		Q = dataset.Q;
	else
		% calling method : trainmsvm(X,Y, options, modelname)
		if nargin < 3
			options = '-u';	% no normalization by default
		else
			if any(strfind(options, '-n') ) == 0
				options = strcat(options,' -u');
			end
		end
		if nargin < 4
			modelname = 'noname';		
		end
	end
	
	[N,d] = size(X); 
		
	modelfile = sprintf('%s.model', modelname);
	
	% Write data file 
	trainfile = sprintf('%s.train', modelname);
	status = writemsvmdata(trainfile, X,Y);
	if status == -1;
		model = -1;
        system('fail to write msvm data','-echo');
		return;
	end
	
	% Call trainmsvm 
	if(strncmp(computer('arch'), 'win', 3))
		command = sprintf('%s\\trainmsvm %s %s %s', msvmpackdir, trainfile, modelfile, options);
	else
		command = sprintf('%s/trainmsvm %s %s %s', msvmpackdir, trainfile, modelfile, options);
	end
	[status,cmdout] = system(command,'-echo');
% 	[status,cmdout] = system(command);
    
	
	if status ~= 0;
		model = -1;
		return;
	end
	
	model = loadmsvm(modelname);
end
