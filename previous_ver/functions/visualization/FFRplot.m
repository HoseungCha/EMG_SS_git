clear all; close all; clc
% SVM main
folderpath=fullfile(cd,'data','Feature','FFT.mat');
load(folderpath);
load('WordList.mat');

data=Feature.N.FFT(:,1:10);
[cols,rows]=size(data);
titles_arrangements_for_plot=repmat(namelist2classify,[1,10]);
% [concatenating_plot_data,CDATA]=subplot_concatenating(...
%     data,title4plot,rows,cols,num2plot_on_s,xlimit);

[f,h_uni]=subplot_fullsize(cols, rows, data,titles_arrangements_for_plot)