%% MSVMpack - load model function
%
%	model = loadmsvm( 'modelname' ) 
% 
% Note: modelname must not contain '.model' at the end. 
%
function [model] = loadmsvm(modelname) 
%     if ~strcmp('.model',modelname(end-5:end))
	modelfile = sprintf('%s.model', modelname);
%     else 
%         modelfile=modelname;
%     end
	fp = fopen(modelfile, 'r');
	if fp == -1
		disp('Error opening model file:');
		modelfile
		return;
	end
	
	model.name = modelname; 
	
	model.version = fscanf(fp, '%f', 1);
	
	type = fscanf(fp, '%d', 1); 
	switch type
		case 0
			model.type = 'WW';
			model.longtype = 'Weston and Watkins (WW)';
		
		case 1
			model.type = 'CS';
			model.longtype = 'Crammer and Singer (CS)';
			
		case 2 
			model.type = 'LLW';
			model.longtype = 'Lee, Lin and Wahba (LLW)';
			
		case 3
			model.type = 'MSVM2';
			model.longtype = 'Guermeur and Monfrini M-SVM^2 (MSVM2)';
			
		otherwise
			model.type = 'unknown';
			model.longtype = 'unknown';
	end
		
	% Number of categories
	model.Q = fscanf(fp, '%d', 1);
	
	% Kernel 
	model.kernel_type = fscanf(fp, '%d', 1);
	switch mod(model.kernel_type, 10);
		case 1
			model.kernel_longtype = 'Linear';
		case 2
			model.kernel_longtype = 'Gaussian RBF';
		case 3
			model.kernel_longtype = 'Homogeneous polynomial';
		case 4
			model.kernel_longtype = 'Non-homogeneous polynomial';
		case 5
			model.kernel_longtype = 'Custom 1';
		case 6
			model.kernel_longtype = 'Custom 2';
		case 7
			model.kernel_longtype = 'Custom 3';

		otherwise
			model.kernel_longtype = 'unknown';
	end
	
	% Kernel parameters
	model.nb_kernel_par = fscanf(fp, '%d', 1);
	model.kernel_par = ( fscanf(fp, '%f', model.nb_kernel_par) )';
	
	% Training info
	model.training_set_name = fscanf(fp, '%s', 1);
	model.training_error = fscanf(fp, '%f', 1);
	
	% Data
	model.nb_data = fscanf(fp, '%d', 1);
	model.dim_input = fscanf(fp, '%d', 1);	
	% model.datatype =  floor(model.kernel_type ./ 10); % use only Double format in matlab...
	
	% Hyperparameter C (one for each category)
	model.C = fscanf(fp, '%f', model.Q); 
	
	% Normalization
	normalization = fscanf(fp, '%f', 1);
	if normalization >= 0 
		model.normalization = zeros(2, model.dim_input);
		model.normalization(2,1) = normalization;
		model.normalization(2,2:end) = ( fscanf(fp, '%f', model.dim_input - 1 ) )' ;
		model.normalization(1,:) = ( fscanf(fp, '%f', model.dim_input) )' ;		
	else 
		model.normalization = [];
	end
	
	% Model parameters (b and alpha) and data (X,Y)
	model.b = fscanf(fp, '%f', model.Q);
	
	model.alpha = zeros(model.nb_data,model.Q);
	model.X = zeros(model.nb_data,model.dim_input);
	model.Y = zeros(model.nb_data,1);	
	for i=1:model.nb_data
		model.alpha(i,:) = ( fscanf(fp,'%f', model.Q) )';
		model.X(i,:) = ( fscanf(fp,'%f', model.dim_input) )';
		model.Y(i) = fscanf(fp, '%d', 1);
	end
	
	model.SVindex = find(sum(abs(model.alpha),2) > 0);
	
	fclose(fp);
	
end
