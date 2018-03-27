%% MSVMpack - k-fold cross validation 
%
%	[cv_error, labels] = kfold(nFolds, X, Y, options)
%
%  Inputs: 
%	nFolds	: number of folds for the cross-validation procedure (typically 5 or 7)
%	X	: (nb_instances X nb_features)-data matrix
%	Y	: (nb_instances)-vector of labels 
%	options	: optional arguments for training (see 'help trainmsvm')
%
%  Outputs:
%	cv_error: estimated cross-validation error 
%	labels	: (nb_instances)-vector of predicted labels 
%				this is a concatenation of the labels predicted 
%				in each data subset without information about 
%				this subset during training). 
%
function [cv_error, labels_reordered] = kfold(nFolds, X,Y,options)

	if isstruct(X)
		% calling method : kfold(nFolds,dataset, options)
		dataset = X;
		modelname = dataset.name;
		X = dataset.X;
		Y = dataset.Y;
		Q = dataset.Q;
	else
		% calling method : kfold(nFolds,X,Y, options)
		if nargin < 4
			options = '-u';	% no normalization by default
		else
			if any(strfind(options, '-n') ) == 0
				options = strcat(options,' -u');
			end
		end
		modelname = 'noname';		
		
	end
	
	[N,d] = size(X); 
	
	if nFolds < 2 | nFolds > N 
		error('kfold: K must be an integer in [2, size(X,1)]');
	end
	
	% Random permutation of examples
	indexes = randperm(N);
	X = X(indexes,:);
	Y = Y(indexes);

	% Make subsets
	sizeFold = floor(N / nFolds);
	
	for fold = 1:nFolds-1 
		idxTest{fold} = (fold - 1)* sizeFold + 1: fold*sizeFold;
		idxTrain{fold} = (1:N);
		idxTrain{fold}(idxTest{fold}) = [];
	end
	% Last fold gets leftovers
	idxTest{nFolds} = idxTest{nFolds-1}(end) + 1:N;
	idxTrain{nFolds} = (1:N);	
	idxTrain{nFolds}(idxTest{nFolds}) = [];
	
	% Train and test all models
	labels = zeros(N,1);
	for fold = 1:nFolds
		model = trainmsvm(X(idxTrain{fold},:) , Y(idxTrain{fold}), options);
		labels(idxTest{fold}) = predmsvm(model, X(idxTest{fold},:) , Y(idxTest{fold}));
	end
	
	% Compute cross-validation error
	cv_error = sum(labels ~= Y) / N;
	
	% Re-order labels 
	labels_reordered = zeros(N,1);
	for i=1:N
		labels_reordered(i) = labels(find(indexes==i,1));
	end
end
