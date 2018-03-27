% DTW를 이용하여, 자신의 Feature와 유사한 다른 사람으로 부터 데이터로 부터
% Feature 찾는 코드 Example

%추가/수정된 부분 by Dr. Won-Du Chang---------------------------------
data = cell(3,1);
data_norm = cell(3,1);
data_vNorm = cell(3,1);
data_reSampled = cell(3,1);
data_transformed = cell(3,1);
option.nDivision_4Resampling = 10;
%추가/수정된 부분 끝-------------------------------------------------

% 자신의 Feature ('Angry')
data{1} = [2.07513356921218;2.17969130222552;4.81269811739876;13.2748894772180;10.1257681787758;6.14369213238716;3.31101612959086;5.48431992213507;13.5094939958662;10.1312112530324;5.80203391814630;5.46125209889299;14.0649478553056;11.1440997271417;6.91042945765733;14.2136111578504;11.2748803157094;7.66380990810005;16.8226708996690;14.8118616554470;11.8057322847294];

% 타인의 비슷한 Feature ('Angry')
data{2} = [3.18059456742333;3.61720039369382;7.94090206538772;13.0021659613603;11.6377527710582;7.59848884191510;5.12480034265481;8.72380805409020;13.5844180258114;11.5070200073861;7.00480902770399;8.96501137459982;14.0122356020490;13.2760618675032;8.87720044711717;13.9121271343891;14.1069747236225;10.7848822118420;17.4450402560809;14.9140136891518;12.4572961590560];

% 타인의 Feature ('Angry')
data{3} = [23.3963116605299;11.6486607834517;25.8064928997933;32.2481768011530;9.05592407108962;9.89356369041894;25.4045415533978;38.6841767954897;40.7103994710861;25.1038082286320;26.5404316205672;29.7919508400740;34.8776126328382;14.2589652821442;16.1420922624942;42.3785486637678;28.2184080628963;28.1025716915517;34.0866651721138;33.3530480049894;13.8416847889871];

%추가된 부분 by Dr. Won-Du Chang------------------------------------------
%Normalization
data_norm{1} = data{1};
data_norm{2} = NormalizeFeature_4DTW(data{1},data{2});
data_norm{3} = NormalizeFeature_4DTW(data{1},data{3});

%Add additional Data

data_reSampled{1} = Resampling(data_norm{1},option.nDivision_4Resampling);
data_reSampled{2} = Resampling(data_norm{2},option.nDivision_4Resampling);
data_reSampled{3} = Resampling(data_norm{3},option.nDivision_4Resampling);

%Vectorization
data_vNorm{1} = vectorize(data_norm{1});
data_vNorm{2} = vectorize(data_norm{2});
data_vNorm{3} = vectorize(data_norm{3});

% DTW를 계산 두 Feature 간의 거리 (유사도) 계산
max_slope_length = 3;
speedup_mode = 1;



[dist_similar, ~, match_pair_1_2] = fastDPW(data_reSampled{1}, data_reSampled{2}, max_slope_length, speedup_mode)  ;                 
[dist_similar, ~, match_pair_1_3] = fastDPW(data_reSampled{1}, data_reSampled{3}, max_slope_length, speedup_mode )  ;    

data_transformed{2} = transfromData_accDTWresult(data_reSampled{2}, data_reSampled{1}, match_pair_1_2, option.nDivision_4Resampling);
data_transformed{3} = transfromData_accDTWresult(data_reSampled{3}, data_reSampled{1}, match_pair_1_3, option.nDivision_4Resampling);
  
  
  
% 그림 출력
figure;
subplot(2,1,1);
plot(data_norm{1})
hold on
plot(data_norm{2});
hold on;
plot(data_norm{3})
legend('data 1', 'data 2', 'data 3');
subplot(2,1,2);
plot(data_norm{1})
hold on
plot(data_transformed{2});
hold on;
plot(data_transformed{3})
legend('data 1(ref)', 'data 2 (transformed)', 'data 3 (transformed)');