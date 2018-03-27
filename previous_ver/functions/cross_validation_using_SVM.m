function CV=cross_validation_using_SVM(data,label,Kfold)
%% Control Pannel

classification_method='MDM'; % SVM, MDM, DGF_MDM
%% mSVM parameters
if strcmp(classification_method,'SVM')
    SVM_model_list={'CS';'LLW';'MSVM2'};
    kernelfuction_list={'1';'2';'3';'4'};
    i_model=3;
    i_kernel=2;
end
%% MDM classfication paratmeters
if strcmp(classification_method,'MDM') || strcmp(classification_method,'DGF_MDM')
    metric_mean = {'euclid','logeuclid','riemann','ld'};
    metric_dist = {'euclid','logeuclid','riemann','ld','kullback'};
    acc = zeros(length(metric_mean),length(metric_dist));
end
%% Feature Demension reduction Method
demsion_reduction_method='none';
d=100 % dimension
% demsion_reduction_method='Fisher';
% demsion_reduction_method='PCA';
% demsion_reduction_method='LDA';
if strcmp(demsion_reduction_method,'none') || strcmp(demsion_reduction_method,'Fisher')
    use_compute_mapping_tool=0;
else
    use_compute_mapping_tool=1;
    prompt={'do supervised feature reduction(Yes:1,No2)'};
    supervised=str2double(inputdlg(prompt));
end







%% retrive data
class4svm=label;
CVO = cvpartition(class4svm,'KFold',Kfold);

if use_compute_mapping_tool
    if supervised
        demsion_reduction_method={'LDA','NCA','LMNN'};%,'MCML'
    else
        demsion_reduction_method={'PCA','ProbPCA','FactorAnalysis',...
            'Isomap','LandmarkIsomap','CCA','KernelPCA' }; %GPLVM,Sammon
    end
end

% for i_model=1:length(SVM_model_list)
for i_demsion_reduction_method=1
    for k=1:CVO.NumTestSets
        
        indices_for_test = CVO.test(k); indices_for_train =  CVO.training(k);
        %  차원축소
        
        if use_compute_mapping_tool
            if  supervised
                input_data=[class4svm(indices_for_train,:),data(indices_for_train,:)];
            else
                input_data=data(indices_for_train,:);
            end
            [mapped_data, mapping] = compute_mapping(input_data,...
                demsion_reduction_method{i_demsion_reduction_method},d);
        else
            if strcmp(demsion_reduction_method,'none')
                mapped_data=data(indices_for_train,:);
                
            elseif strcmp(demsion_reduction_method,'Fisher')
                train_data=data(indices_for_train,:);
                c_train_data=class4svm(indices_for_train,:);
                [out] = fsFisher(train_data,c_train_data);
                % plot
                W4plot=sort(out.W,'descend');
                plot(W4plot)
                index2usefeaure=out.fList(1:d);
                mapped_data=train_data(:,index2usefeaure);
            end
        end
        
        % Fisher Score
        
        %% Trainning by SVM
        if strcmp(classification_method,'SVM')
            eval(sprintf('trainmsvm(mapped_data,class4svm(indices_for_train,:), ''-m %s -k %s -n myTraining.log'', ''model'');',...
                SVM_model_list{i_model},...
                kernelfuction_list{i_kernel}...
                ));
        end
        
        %% Classification for Test
        
        
        if use_compute_mapping_tool
            testdata4svm = out_of_sample(data(indices_for_test,:), mapping);
        else
            if strcmp(demsion_reduction_method,'none')
                testdata4svm=data(indices_for_test,:);
                %                 testdata4svm=data4svm(indices_for_test,:)*mapping.M;
                
            elseif strcmp(demsion_reduction_method,'Fisher')
                testdata4svm=data(indices_for_test,:);
                testdata4svm=testdata4svm(:,index2usefeaure);
            end
        end
        if strcmp(classification_method,'SVM')
            model_name= 'model';
            
            [estLabels, outputs] = predmsvm(model_name,testdata4svm,...
                class4svm(indices_for_test,:),'-n');
            trueLabels=class4svm(indices_for_test,:);
            C = confusionmat(trueLabels,estLabels);
            C = C./repmat(sum(C,2),1,size(C,2));
            C = C*100;
            
            mean_accr=mean(diag(C));
            CV.trueLabels{k,1}=trueLabels;
            CV.estLabels{k,1}=estLabels;
            CV.outputs{k,1}=outputs;
            %     CV.fscored=out;
            CV.mean_accr{k,1}=mean_accr;
            CV.confustionmatrix{k,1}=C;
        end
        
        if strcmp(classification_method,'MDM')
            COVtrain=permute(reshape(mapped_data,[133,10,10]),[2 3 1]);
            COVtest=permute(reshape(testdata4svm,[7,10,10]),[2 3 1]);
            %         Ytrain=find(indices_for_train==1);
            %         trueYtest=find(indices_for_test==1);
            Ytrain=class4svm(indices_for_train,:);
            trueYtest=class4svm(indices_for_test,:);
            
            for i=1:length(metric_mean)
                for j=1:length(metric_dist)
                    %             for j=1:4
                    Ytest = mdm(COVtest,COVtrain,Ytrain,metric_mean{i},metric_dist{j});
                    acc(i,j) = 100*mean(Ytest==trueYtest);                    
                end
            end
            
            disp('------------------------------------------------------------------');
            disp('Accuracy (%) - Rows : distance metric, Colums : mean metric');
            disp('------------------------------------------------------------------');
            displaytable(acc',metric_mean,10,{'.1f'},metric_dist)
            disp('------------------------------------------------------------------');
            CV.mean_accr{k,1}=acc;
        end
        
    end
    mean_Kfold=zeros(CVO.NumTestSets,1);
    for i_k=1:CVO.NumTestSets
        mean_Kfold(i_k,1)=CV.mean_accr{i_k,1};
    end
    CV.accuracy=mean(mean_Kfold);
    CV.accuracy
    
    diary OFF
end
% end