addpath(genpath(fullfile(cd,'functions')));
% addpath(genpath('D:\10_연구프로젝트\01_Speech_Recognition\분석\matlab'));
%% read file

[FileName,PathName] = uigetfile('*mat','Select online test file');
OUTEEG = load(fullfile(PathName,FileName));
%% get accuracy from online code
estLabels=zeros(OUTEEG.File_Header.ExperimentBuffers.n_trial-1,1);
for jj=1:OUTEEG.File_Header.ExperimentBuffers.n_trial-1
    estLabels(jj,1)=OUTEEG.File_Header.ExperimentBuffers.trial_data{jj}.classification.estLabels{1};
%     trueLabels(jj,1)=OUTEEG.File_Header.ExperimentBuffers.trial_data{1, 1}.classification.trueLabels;
end
trueLabels=OUTEEG.File_Header.ExperimentParameters.training_sequence4backup;
C = confusionmat(trueLabels,estLabels);
C = C./repmat(sum(C,2),1,size(C,2));
C = C*100;
disp(mean(diag(C)));
