%% read file
[FileName,PathName] = uigetfile('*mat','Select online test file');
OUTEEG = load(fullfile(PathName,FileName));
final_featureset=[];
% load trial data from buffer

final_labelset=OUTEEG.File_Header.ExperimentParameters.training_sequence4backup;
for jj=1:length(OUTEEG.File_Header.ExperimentBuffers.trial_data)-1
    temp=OUTEEG.File_Header.ExperimentBuffers.trial_data{jj,1}.feature{1, 1}';
    final_featureset=[final_featureset;temp];
    temp_label=OUTEEG.File_Header.ExperimentBuffers.trial_data{jj, 1}.classification.trueLabels;
end

% final_labelset=repmat

X=final_featureset;
Y=final_labelset;
selectedFeature=X;
ii=1;
% crossvalidation_using_mSVM;
trainmsvm(X,Y, '-m MSVM2 -k 2 -n -cv 20 myTraining.log', 'online_svm_model');
trainmsvm(X,Y, '-m MSVM2 -k 2 -n myTraining.log', 'online_svm_model');
copyfile('online_svm_model.model',PathName);
copyfile('online_svm_model.outputs',PathName)
copyfile('online_svm_model.test',PathName)
copyfile('online_svm_model.train',PathName)
% end