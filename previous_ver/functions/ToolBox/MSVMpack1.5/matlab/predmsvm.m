%% MSVMpack prediction function for Matlab
%
%	[labels] = predmsvm(model, X, Y)
%  or
%	[labels, outputs] = predmsvm(model, X, Y)
%
%  Inputs: 
%       model : a trained MSVM model (or a string with model name)
%           X : matrix of test data (nb_data x nb_features)
%           Y : vector of test labels (nb_data x 1)  
%
%  Outputs:
%      labels : predicted labels (nb_data x 1)
%     outputs : matrix of MSVM outputs (nb_data x nb_categories)

function [labels, outputs] = predmsvm(model, X, Y, ncpus)
	[N,d] = size(X);
	
	if nargin < 3
		Y = ones(N,1);
	end
	if nargin < 4
		options = ' ';
	else
		options = sprintf('-t %d',ncpus);
	end
	if strcmp(class(model), 'char') 
		modelname = model;
		model = loadmsvm(modelname);
	else
		modelname = model.name;
	end
	
	% Write data file 
	testfile = sprintf('%s.test', modelname); 
	
	status = writemsvmdata(testfile, X, Y);
	if status == -1
		return;
	end
	
	Q = model.Q;
	
	% Call predmsvm 
	outputfile = sprintf('%s.outputs', modelname);
	if(strncmp(computer('arch'), 'win', 3))
		command = sprintf('%s\\predmsvm %s %s.model %s %s', msvmpackdir,testfile, modelname, outputfile, options);
	else
		command = sprintf('%s/predmsvm %s %s.model %s %s', msvmpackdir,testfile, modelname, outputfile, options);
    end
    
%      if bEcho==1
 %        [status,cmdout] = system(command,'-echo');
         [status,cmdout] = system(command);
%      end
	
	% Read output file
	outputs = zeros(N, Q);
	labels = zeros(N,1);
	
	fp = fopen(outputfile, 'r');
	if fp == -1
		disp('Error opening file:');
		outputfile
		disp('predmsvm probably failed.');
		return;
	end
	
	
	for i=1:N
		outputs(i,:) = fscanf(fp, '%f', Q);
		labels(i) = fscanf(fp,'%d', 1);
	end
	fclose(fp);
end
