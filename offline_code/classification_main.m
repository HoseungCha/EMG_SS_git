%----------------------------------------------------------------------
% EMG speech onset 부분 추출하여 합치는 코드
%----------------------------------------------------------------------
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan Im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
%---------------------------------------------------------------------
clear; close all; clc

addpath(genpath(fullfile(cd,'functions'))); % 함수

DB_path = 'E:\OneDrive_Hanyang\연구\EMG_Silent_Search\코드'; % main path
fullfile(DB_path,'DB','DB_processed'); % saving path

