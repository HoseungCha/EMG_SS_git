% function (X,Y,
% parmaeters setup
Kfold=20; % 5원래 사용, 10, 20(leave one out)
interation=10;
class4svm=Y;
CVO = cvpartition(class4svm,'KFold',Kfold);
data4svm=selectedFeature;
% data4svm=X;
d=50;

demsion_reduction_method='none';
use_compute_mapping_tool=0;
supervised=0;
if use_compute_mapping_tool
if supervised
    demsion_reduction_method={'LDA','NCA','MCML','LMNN'};
else
    demsion_reduction_method={'PCA','ProbPCA','FactorAnalysis',...
        'GPLVM','Sammon','Isomap','LandmarkIsomap','CCA','KernelPCA' };
end
end
% demsion_reduction_method='PCA';
% demsion_reduction_method='Fisher';
% prepare data for mSVM
% 표정 Trails 단어20개 * 10 = 200개
SVM_model_list={'CS';'LLW';'MSVM2'};
kernelfuction_list={'1';'2';'3';'4'};
% for i_iteration=1:interation
% %     CVO = cvpartition(class4svm,'KFold',Kfold);
%     cnew = repartition(CVO);
%     isequal(test(CVO,1),test(cnew,1))
% for i_demsion_reduction_method=1:length(demsion_reduction_method)
%     disp(demsion_reduction_method{i_demsion_reduction_method});
    
    for i_model=3
        for i_kernel=2
            %         disp(SVM_model_list{i_model});
            %         disp(kernelfuction_list{i_kernel});
            
            for k=1:CVO.NumTestSets
                
                indices_for_test = CVO.test(k); indices_for_train =  CVO.training(k);
                % Denote train sessions
                %  차원축소
                
                if use_compute_mapping_tool
                    if  supervised
                        input_data=[class4svm(indices_for_train,:),data4svm(indices_for_train,:)];
                    else
                        input_data=data4svm(indices_for_train,:);
                    end
                    [mapped_data, mapping] = compute_mapping(input_data,...
                        demsion_reduction_method{i_demsion_reduction_method},d);
                else
                    if strcmp(demsion_reduction_method,'none')
                        mapped_data=data4svm(indices_for_train,:);
                        
                    elseif strcmp(demsion_reduction_method,'Fisher')
                        train_data=data4svm(indices_for_train,:);
                        c_train_data=class4svm(indices_for_train,:);
                        [out{ii,1}] = fsFisher(train_data,c_train_data);
                        index2usefeaure=out{ii}.fList(1:d);
                        mapped_data=train_data(:,index2usefeaure);
                    end
                end
                
                
                % Fisher Score
                
                
                % Trainning
                eval(sprintf('trainmsvm(mapped_data,class4svm(indices_for_train,:), ''-m %s -k %s -n myTraining.log'', ''model'');',...
                    SVM_model_list{i_model},...
                    kernelfuction_list{i_kernel}...
                    ));
                
                
                
                %% Classification for Test
                model_name= 'model';
                
                if use_compute_mapping_tool
                    testdata4svm = out_of_sample(data4svm(indices_for_test,:), mapping);
                else
                    if strcmp(demsion_reduction_method,'none')
                        testdata4svm=data4svm(indices_for_test,:);
                        %                 testdata4svm=data4svm(indices_for_test,:)*mapping.M;
                        
                    elseif strcmp(demsion_reduction_method,'Fisher')
                        testdata4svm=data4svm(indices_for_test,:);
                        testdata4svm=testdata4svm(:,index2usefeaure);
                    end
                end
                [estLabels, outputs] = predmsvm(model_name,testdata4svm,...
                    class4svm(indices_for_test,:),'-n');
                trueLabels=class4svm(indices_for_test,:);
                C = confusionmat(trueLabels,estLabels);
                C = C./repmat(sum(C,2),1,size(C,2));
                C = C*100;
                %             disp(diag(C));
                disp(mean(diag(C)));
                mean_accr=mean(diag(C));
                CV(ii).estLabels{k,1}=estLabels;
                CV(ii).outputs{k,1}=outputs;
                CV(ii).mean_accr{k,1}=mean_accr;
                CV(ii).confustionmatrix{k,1}=C;
%                 CV(ii).selectedChannel=chList4validation(ii,:);
            end
            mean_Kfold=zeros(CVO.NumTestSets,1);
            for i_k=1:CVO.NumTestSets
                mean_Kfold(i_k,1)=CV(ii).mean_accr{i_k,1};
            end
            CV(ii).accuracy=mean(mean_Kfold);
            CV(ii).accuracy
            %         if CV(ii).accuracy>80
            %             keyboard
            %         end
        end
    end
    % end
% end
diary OFF